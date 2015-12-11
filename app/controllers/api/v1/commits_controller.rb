class Api::V1::CommitsController < ApplicationController

	def index
		@commits = Commit.all
		render json: @commits
	end

end
