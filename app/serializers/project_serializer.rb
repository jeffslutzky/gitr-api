class ProjectSerializer < ActiveModel::Serializer
	# has_many :milestones
	embed :ids

  attributes :id, :name

  def attributes
    attributes = super
    attributes[:milestones] = object.milestones.try(:as_json)
    attributes[:issues] = object.issues.try(:as_json)
    attributes[:commits] = object.commits.try(:as_json)
    attributes
  end
end
