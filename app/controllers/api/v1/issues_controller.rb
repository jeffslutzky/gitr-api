class Api::V1::IssuesController < ApplicationController

	def index
		@issues = Issue.all
		render json: @issues
	end

end
