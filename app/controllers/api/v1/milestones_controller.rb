class Api::V1::MilestonesController < ApplicationController

	def index
		@milestones = Milestone.all
		render json: @milestones
	end

end
