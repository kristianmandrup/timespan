module Timespan
	module Rails
		class Engine < ::Rails::Engine
			initializer 'Timespan setup' do
				I18n.load_path << Dir[Rails.root.join('config', 'locales', 'timespan', '*.yml')]
			end
		end
	end
end