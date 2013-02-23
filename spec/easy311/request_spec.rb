describe Easy311::Request do

  describe "responds to method missing" do

    subject do
      service = FactoryGirl.build(:easy311_service, attrs: [
        FactoryGirl.build(:easy311_attribute, :code => "some_attribute")])
      Easy311::Request.new(service)
    end
    it { should respond_to(:some_attribute) }
    it { should respond_to(:some_attribute=) }
    it { should_not respond_to(:invalid_attribute) }
    it { should_not respond_to(:invalid_attribute=) }
    it "writes Easy311 attribute values to ActiveAttr's" do
      subject.some_attribute = 'Value 123'
      subject.some_attribute.should == 'Value 123'
    end

    it "merges ActiveAttr and Easy311 fields when calling #attributes" do
      subject.some_attribute = "some_value"
      subject.attrs_values.should have_key("some_attribute")
    end

    it "has the same value in attributes" do
      subject.some_attribute = "some_value"
      subject.attributes["attrs"]["some_attribute"].should == "some_value"
    end

  end

  describe "generates attributes to send to api_wrapper" do

    it "converts lat and long" do
      service = FactoryGirl.build(:easy311_service)
      service.code = "1234"

      request = Easy311::Request.new(service)
      request.lat = 12.23
      request.long = 23.34

      expected = {
        'service_code' => "1234",
        'lat' => 12.23,
        'long' => 23.34,
      }

      request.to_post_params.should == expected
    end

    it "converts all attributes to send to api_wrapper" do
      service = FactoryGirl.build(:easy311_service)
      service.code = "1234"

      params = {
        'service_code' => service.code,
        'description' => "desc",
        'lat' => 12.34,
        'long' => 56.78,
        'email' => "email@test.com",
        'device_id' => 1,
        'account_id' => 2,
        'first_name' => "firstname",
        'last_name' => "lastname",
        'phone' => "55512345678",
        'description' => "description",
        'media_url' => "http://url"
      }

      request = Easy311::Request.new(service)
      params.except('service_code').each do |key, value|
        request.send("#{key}=", value)
      end

      request.to_post_params.should == params
    end

    it "converts question values to send to api_wrapper" do
      service = FactoryGirl.build(:easy311_service)
      service.code = "1234"

      request = Easy311::Request.new(service)
      request.lat = 12.34
      request.long = 23.45
      request.attrs_values['value1'] = "param1"

      expected = {
        'service_code' => "1234",
        'lat' => 12.34,
        'long' => 23.45,
        'attribute[value1]' => "param1",
      }

      request.to_post_params.should == expected
    end

  end

  describe "validations" do
    it "responds to valid?" do
      FactoryGirl.build(:easy311_service).should respond_to(:valid?)
    end

    it "validates required attributes" do
      required_attr = FactoryGirl.build(:easy311_attribute, required: true)
      service = FactoryGirl.build(:easy311_service, :attrs => [required_attr])

      request = Easy311::Request.new(service)
      request.valid?.should be_false
      request.errors.should have_key(required_attr.code.to_sym)
    end
  end

end

