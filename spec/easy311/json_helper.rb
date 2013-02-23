# encoding: utf-8
def min_sample_service(opts={})
  {
    "service_code"=>"1934303d-7f43-e111-85e1-005056a60032",
    "service_name"=>"Collecte des encombrants - secteur résidentiel",
    "group"=>"Ordures",
    "description"=>"Description à venir",
    "metadata"=>true,
    "type"=>"batch"
  }.merge(opts)
end

def sample_service(opts={})
  {
    "description"=>"Description à venir",
    "group"=>"Ordures",
    "keywords"=> "Collecte,Encombrants,Gros déchets,Grosses poubelles,Grosses vidanges,Meubles,Monstres",
    "metadata"=>true,
    "service_code"=>"1934303d-7f43-e111-85e1-005056a60032",
    "service_name"=>"Collecte des encombrants - secteur résidentiel",
    "type"=>"batch"
  }.merge(opts)
end

def sample_attribute
  {
     "attributes"=> [one_attribute]
  }
end

def one_attribute(opts={})
  {
    "code"=>"7041ac51-ec75-e211-9483-005056a613ac",
    "datatype"=>"text",
    "datatype_description"=> "Pour disposer d`appareils contenant des halocarbures (congélateur, réfrigérateur, climatiseur, etc.), veuillez communiquer avec votre bureau d'arrondissement.",
    "description"=> "Pour disposer d`appareils contenant des halocarbures (congélateur, réfrigérateur, climatiseur, etc.), veuillez communiquer avec votre bureau d'arrondissement.",
    "order"=>2,
    "required"=>false,
    "values"=>[],
    "variable"=>false
  }.merge(opts)
end

def sample_response(opts={})
  {
    "account_id" => nil,
    "service_notice" => nil,
    "service_request_id" => nil,
    "token" => "c5f0d6ad-59ca-44a4-86e8-a2d72708f54c"
  }.merge(opts)
end
