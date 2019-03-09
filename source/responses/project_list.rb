# frozen_string_literal: true

module Responses
	module ProjectList
		extend self

		def generate_list(user_id)
			JSON.generate(
				{
					user_id: user_id,
					projects: fetch_projects(user_id)
				}
			)
		end

		def fetch_projects(user_id)
			[
				{
					name: "project1",
					users: [
						{
							name: "Marcin Raszkiewicz",
						},
					],
				},
				{
					name: "project2",
					users: [
						{
							name: "Edward Gierek",
						},
						{
							name: "Zbigniew Stonoga",
						},
					],
				},
			]
		end
	end
end
