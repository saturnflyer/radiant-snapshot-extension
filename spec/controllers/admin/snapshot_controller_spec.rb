require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::SnapshotController do

  #Delete these examples and add some real ones
  it "should use Admin::SnapshotController" do
    controller.should be_an_instance_of(Admin::SnapshotController)
  end


  it "GET 'index' should be successful" do
    get 'index'
    response.should be_success
  end

  it "GET 'create' should be successful" do
    get 'create'
    response.should be_success
  end
end
