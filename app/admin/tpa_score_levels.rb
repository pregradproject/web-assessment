ActiveAdmin.register_page 'Tpa Score Levels' do
  menu label: 'TPA Score Levels', priority: 15, parent: 'Configs'

  content do
    render 'tpa_score_levels_form'
  end

  page_action :update, method: :post do
    begin
      levels = {
        'low' => {
          'name' => params[:low_name],
          'min_score' => params[:low_min_score].to_i,
          'max_score' => params[:low_max_score].to_i,
          'label' => params[:low_label],
          'message' => params[:low_message]
        },
        'average' => {
          'name' => params[:average_name],
          'min_score' => params[:average_min_score].to_i,
          'max_score' => params[:average_max_score].to_i,
          'label' => params[:average_label],
          'message' => params[:average_message]
        },
        'high' => {
          'name' => params[:high_name],
          'min_score' => params[:high_min_score].to_i,
          'max_score' => params[:high_max_score].to_i,
          'label' => params[:high_label],
          'message' => params[:high_message]
        }
      }

      # Validate score ranges
      errors = []
      levels.each do |level_key, level_config|
        if level_config['min_score'] >= level_config['max_score']
          errors << "#{level_config['name']}: Minimum score must be less than maximum score"
        end
      end

      if levels['low']['max_score'] >= levels['average']['min_score']
        errors << 'Low category maximum score must be less than Average category minimum score'
      end

      if levels['average']['max_score'] >= levels['high']['min_score']
        errors << 'Average category maximum score must be less than High category minimum score'
      end

      if errors.any?
        flash[:error] = errors.join('<br>').html_safe
        redirect_to admin_tpa_score_levels_path
        return
      end

      Configs::ConfigServices.set_tpa_score_levels(levels)
      flash[:notice] = 'TPA score levels updated successfully'
      redirect_to admin_tpa_score_levels_path
    rescue => e
      flash[:error] = "Error updating TPA score levels: #{e.message}"
      redirect_to admin_tpa_score_levels_path
    end
  end

  page_action :reset, method: :post do
    Configs::ConfigServices.clear_cache('tpa_score_levels')
    # Reset to defaults by deleting the config
    config = Config.find_by(key: 'tpa_score_levels')
    config.destroy if config

    flash[:notice] = 'TPA score levels reset to defaults'
    redirect_to admin_tpa_score_levels_path
  end

  controller do
    def index
      @current_levels = Configs::ConfigServices.tpa_score_levels
      super
    end
  end
end
