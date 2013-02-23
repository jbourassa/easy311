# encoding: UTF-8
require 'spec_helper'
require 'easy311/json_helper.rb'
require 'json'

class ResponseStub

  def initialize(response)
    @response = response
  end

  def get(params)
    return @response
  end

end

class GetStub
  attr_accessor :get

  def initialize
    @responses = {}
  end

  def add_response(url, response)
    @responses[url] = response
  end

  def [](key)
    return ResponseStub.new(@responses[key])
  end

end

class PostStub

  def initialize(response)
    @response = response
  end

  def [](key)
    return self
  end

  def post(payload)
    code = 200
    @result = payload
    resp = Struct.new(:code, :body).new(code, @response)
    yield resp
  end

  def post_result
    @result
  end

end

class ErrorStub < PostStub

  def post(payload)
    code = 400
    body = "[{\"code\":\"Forbidden\",\"description\":\"'api_key' : L'argument ne peut pas \xC3\xAAtre null ou vide.\"}]"
    response = Struct.new(:code, :body).new(code, body)
    yield response
  end

end

api_key = "12345678-1234-A1B2-C3D4-AA1A111A1A1A"

describe Easy311::ApiWrapper do

  it "returns an empty list when no services" do
    resource = GetStub.new
    resource.add_response('/services.json', "")

    wrapper = Easy311::ApiWrapper.new(resource, api_key)
    wrapper.all_services.should == []
  end

  it "returns once service" do
    resource = GetStub.new()
    service_json = [sample_service].to_json
    resource.add_response('/services.json', service_json)

    wrapper = Easy311::ApiWrapper.new(resource, api_key)
    all_services = wrapper.all_services

    all_services.length.should == 1
    service = all_services.first

    service.name.should == sample_service['service_name']
    service.code.should == sample_service['service_code']
    service.group.should == sample_service['group']
    service.description.should == sample_service['description']
    service.metadata.should == sample_service['metadata']
    service.type.should ==  sample_service['type']
    service.to_param.should == sample_service['service_code']
  end

  it "returns a service with minimal keys" do
    resource = GetStub.new
    service_json = [min_sample_service].to_json
    resource.add_response('/services.json', service_json)

    wrapper = Easy311::ApiWrapper.new(resource, api_key)
    all_services = wrapper.all_services

    all_services.length.should == 1
    service = all_services[0]

    service.name.should == sample_service['service_name']
    service.code.should == sample_service['service_code']
    service.group.should == sample_service['group']
    service.description.should == sample_service['description']
    service.metadata.should == sample_service['metadata']
    service.type.should ==  sample_service['type']
    service.to_param.should == sample_service['service_code']
  end

  it "returns the names of the groups" do
    resource = GetStub.new
    service_json = [min_sample_service].to_json
    resource.add_response('/services.json', service_json)

    wrapper = Easy311::ApiWrapper.new(resource, "1234")

    wrapper.group_names.should == ["Ordures"]
  end

  it "returns a single group name with 2 services" do
    resource = GetStub.new
    service_json = [sample_service, sample_service].to_json
    resource.add_response('/services.json', service_json)

    wrapper = Easy311::ApiWrapper.new(resource, "1234")

    result = ["Ordures"]
    expect(wrapper.group_names).to eq(result)
  end

  it "returns a single group name with 2 services" do
    resource = GetStub.new
    second_service = sample_service.dup
    second_service['group'] = 'Trottoirs'
    service_json = [sample_service, second_service].to_json
    resource.add_response('/services.json', service_json)

    wrapper = Easy311::ApiWrapper.new(resource, api_key)

    result = ["Ordures", "Trottoirs"]
    wrapper.group_names.should == result
  end

  it "groups services together" do
    resource = GetStub.new
    second_service = sample_service.dup
    second_service['group'] = 'Trottoirs'
    service_json = [sample_service, second_service].to_json
    resource.add_response('/services.json', service_json)

    wrapper = Easy311::ApiWrapper.new(resource, api_key)

    groups = wrapper.groups
    groups.keys.should == ["Ordures", "Trottoirs"]
    groups["Ordures"].should be_an_instance_of(Array)
    groups["Ordures"][0].should be_an_instance_of(Easy311::Service)
  end

  it "returns no attrs with an empty string" do
    resource = GetStub.new
    attribute_json = ""
    resource.add_response('/services/01234-1234-1234-1234.json', attribute_json)

    code = "01234-1234-1234-1234"
    wrapper = Easy311::ApiWrapper.new(resource, "1234")
    attrs = wrapper.attrs_from_code(code)

    attrs.should == []
  end

  it "returns one attribute" do
    resource = GetStub.new
    attribute_json = sample_attribute.to_json
    resource.add_response('/services/01234-1234-1234-1234.json', attribute_json)

    code = "01234-1234-1234-1234"
    wrapper = Easy311::ApiWrapper.new(resource, "1234")
    result = wrapper.attrs_from_code(code)

    expect(result.length).to eq(1)
    attribute = result[0]

    expect(attribute.code).to eq("7041ac51-ec75-e211-9483-005056a613ac")
    expect(attribute.datatype).to eq("text")
    expect(attribute.description).to eq("Pour disposer d`appareils contenant des halocarbures (congélateur, réfrigérateur, climatiseur, etc.), veuillez communiquer avec votre bureau d'arrondissement.")
    expect(attribute.datatype_description).to eq("Pour disposer d`appareils contenant des halocarbures (congélateur, réfrigérateur, climatiseur, etc.), veuillez communiquer avec votre bureau d'arrondissement.")
    expect(attribute.order).to eq(2)
    expect(attribute.required).to eq(false)
    expect(attribute.values).to eq([])
    expect(attribute.variable).to eq(false)
  end

  it "returns a service with an attribute" do
    resource = GetStub.new
    service_json = [sample_service].to_json
    attribute_json = sample_attribute.to_json
    resource.add_response('/services.json', [sample_service].to_json)
    resource.add_response('/services/1934303d-7f43-e111-85e1-005056a60032.json', attribute_json)

    wrapper = Easy311::ApiWrapper.new(resource, "1234")
    services = wrapper.services_with_attrs
    service = services[0]

    expect(service.name).to eq("Collecte des encombrants - secteur résidentiel")
    expect(service.code).to eq("1934303d-7f43-e111-85e1-005056a60032")
    expect(service.group).to eq("Ordures")
    expect(service.description).to eq("Description à venir")
    expect(service.metadata).to eq(true)
    expect(service.type).to eq("batch")

    service.attrs.should be_an_instance_of(Hash)
    attribute = service.attrs.values.first

    expect(attribute.code).to eq("7041ac51-ec75-e211-9483-005056a613ac")
    expect(attribute.datatype).to eq("text")
    expect(attribute.description).to eq("Pour disposer d`appareils contenant des halocarbures (congélateur, réfrigérateur, climatiseur, etc.), veuillez communiquer avec votre bureau d'arrondissement.")
    expect(attribute.datatype_description).to eq("Pour disposer d`appareils contenant des halocarbures (congélateur, réfrigérateur, climatiseur, etc.), veuillez communiquer avec votre bureau d'arrondissement.")
    expect(attribute.order).to eq(2)
    expect(attribute.required).to eq(false)
    expect(attribute.values).to eq([])
    expect(attribute.variable).to eq(false)
  end

  it "sends a request to the api" do
    resource = PostStub.new([sample_response].to_json)
    request = FactoryGirl.build(:easy311_request)

    wrapper = Easy311::ApiWrapper.new(resource, api_key)
    wrapper.send_request(request)

    expected = {
      'api_key' => api_key,
      'service_code' => request.service.code,
      'lat' => request.lat,
      'long' => request.long,
    }

    resource.post_result.should == expected
  end

  it "sends a request with attributes to the api" do
    resource = PostStub.new([sample_response].to_json)
    request = FactoryGirl.build(:easy311_request)
    request.attrs_values = {
      '1234-1234-1234-1234' => '2345-2345-2345-2345',
      '3456-3456-3456-3456' => '4567-4567-4567-4567'
    }

    wrapper = Easy311::ApiWrapper.new(resource, api_key)
    wrapper.send_request(request)

    expected = {
      'api_key' => api_key,
      'service_code' => request.service.code,
      'lat' => request.lat,
      'long' => request.long,
      'attribute[1234-1234-1234-1234]' => '2345-2345-2345-2345',
      'attribute[3456-3456-3456-3456]' => '4567-4567-4567-4567',
    }

    resource.post_result.should == expected
  end

  it "returns a response when sending a request" do
    resource = PostStub.new([sample_response].to_json)
    request = FactoryGirl.build(:easy311_request)
    wrapper = Easy311::ApiWrapper.new(resource, api_key)

    response = wrapper.send_request(request)

    response.account_id.should be_nil
    response.service_notice.should be_nil
    response.service_request_id.should be_nil
    response.token.should == "c5f0d6ad-59ca-44a4-86e8-a2d72708f54c"
  end

  it "raises an exception when api returns a 400 error" do
    resource = ErrorStub.new([sample_response].to_json)
    request = FactoryGirl.build(:easy311_request)

    wrapper = Easy311::ApiWrapper.new(resource, api_key)
    response = wrapper.send_request(request)
    response.invalid?.should == true
    response.error_message.should == "'api_key' : L'argument ne peut pas \xC3\xAAtre null ou vide."
  end

end
