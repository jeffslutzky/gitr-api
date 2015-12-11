class CommitSerializer < ActiveModel::Serializer
  attributes :id, :message
  embed :ids
  # has_one :project

  def attributes
    attributes = super
    attributes[:project] = object.project.try(:as_json)
    attributes
  end

end
