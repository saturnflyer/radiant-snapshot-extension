require 'find'
require 'zip/zip'

class Admin::SnapshotController < ApplicationController
  def index
  end

  def create
    $SNAPSHOT_REQUEST = request
    Page.class_eval {
      def request
        $SNAPSHOT_REQUEST || super
      end
    }
    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    snapshot_name = "snapshot-#{timestamp}"
    snapshot_build_dir = "tmp/#{snapshot_name}"
    snapshot_path = File.expand_path("#{Rails.root}/tmp/#{snapshot_name}.zip")
    FileUtils.rm_rf(snapshot_build_dir) if File.exist?(snapshot_build_dir)
    FileUtils.rm_rf(snapshot_path) if File.exist?(snapshot_path)
    FileUtils.mkdir_p(snapshot_build_dir)
    
    Page.all.each do |p|
      if p.published? && (body = p.render)
        dir, filename = p.url, "index.html"
        dir, filename = p.parent.url, p.slug if p.slug =~ /\.[^.]+$/i # File with extension (e.g. styles.css)
        FileUtils.mkdir_p(File.join(snapshot_build_dir, dir))
        File.open(File.join(snapshot_build_dir, dir, filename), 'w') { |io| io.print(body) }
      else # draft, reviewed
        dir, filename = "#{p.url}/#{p.status.name.downcase}", "index.html"
        dir, filename = "#{p.parent.url}/#{p.parent.status.name.downcase}", p.slug if p.slug =~ /\.[^.]+$/i # File with extension (e.g. styles.css)
        FileUtils.mkdir_p(File.join(snapshot_build_dir, dir))
        File.open(File.join(snapshot_build_dir, dir, filename), 'w') { |io| io.print(body) }
      end
    end
    $SNAPSHOT_REQUEST = nil
    FileUtils.cp_r('public/.', snapshot_build_dir)
    Zip::ZipFile::open("#{snapshot_build_dir}.zip", Zip::ZipFile::CREATE) { |zf| 
      # TODO: skip files like dispatch.rb, *.sass and admin files
       Dir["#{snapshot_build_dir}/**/*"].each { |f| zf.mkdir(f); zf.add(f, f) } 
    }
    send_file snapshot_path, :type => 'application/zip', :disposition => 'attachment', :filename => snapshot_name
    # FileUtils.rm_rf(snapshot_build_dir) if File.exist?(snapshot_build_dir)
    # FileUtils.rm_rf(snapshot_path) if File.exist?(snapshot_path)
    redirect_to admin_pages_path
  end

end
