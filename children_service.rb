# Use this to flatten your hierarchy
require 'rails'
class ChildrenService
  attr_accessor :data
  def initialize(data)
    @data = data
  end

  def flatten_children(children_ids)
    all_flattened_children = []

    children_ids.each do |child_id|
      all_flattened_children << child_id
      inner_children_ids = data.try(:[], child_id).try(:[], 'children')

      if inner_children_ids.present?
        flatten_children(inner_children_ids).each do |item|
          all_flattened_children << item
        end
      end
    end
    all_flattened_children
  end

  class << self
    # This methods helps flatten all nested children for a given id
    def ids_with_flattened_children(data)
      flatten_id_hash = {}
      children_service = self.new(data)
      data.each_pair do |entity_id, corresp_data|
        children_ids = corresp_data['children'] || []
        flatten_id_hash[entity_id] = children_service.flatten_children(children_ids)
      end
      flatten_id_hash
    end
  end

  data_1 = { "123" => { "name" => "Tom", "children" => ["367", "368", "369"] },
             "124" => { "name" => "Jerry" },
             "367" => { "name" => "Scooby" },
             "368" => { "name" => "Dooby", "children" => ["124"] },
             "369" => { "name" => "Doo" } }

  final_data = ids_with_flattened_children(data_1)

  # final_data = { "123"=>["367", "368", "124", "369"],
  #                "124"=>[],
  #                "367"=>[],
  #                "368"=>["124"],
  #                "369"=>[]}
  puts final_data
  
end
