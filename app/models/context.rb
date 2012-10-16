class Context < ActiveRecord::Base
  acts_as_tenant(:account)
  has_and_belongs_to_many :layers
  
  attr_accessible :maxx, :maxy, :minx, :miny, :name, :zoom, :description, :center_lng, :center_lat, :layer_ids, :uuid

  before_create :generate_uuid

  def generate_uuid
    self.uuid = self.account.subdomain.sub("-", "")+"-"+(0...8).map{65.+(rand(26)).chr.downcase}.join
  end
end
