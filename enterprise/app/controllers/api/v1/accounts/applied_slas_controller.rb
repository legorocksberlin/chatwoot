class Api::V1::Accounts::AppliedSlasController < Api::V1::Accounts::EnterpriseAccountsController
  include Sift
  include DateRangeHelper

  RESULTS_PER_PAGE = 25

  before_action :set_appplied_slas, only: [:index, :metrics]
  before_action :set_current_page, only: [:index]
  before_action :set_current_page_appiled_slas, only: [:index]
  before_action :check_admin_authorization?

  sort_on :created_at, type: :datetime

  def index; end

  def metrics
    @total_applied_slas = @applied_slas.count
    @number_of_sla_breaches = @applied_slas.missed.count
  end

  private

  def set_appplied_slas
    @applied_slas = initial_query
                    .filter_by_date_range(range)
                    .filter_by_inbox_id(params[:inbox_id])
                    .filter_by_team_id(params[:team_id])
                    .filter_by_sla_policy_id(params[:sla_policy_id])
                    .filter_by_label_list(params[:label_list])
                    .filter_by_assigned_agent_id(params[:assigned_agent_id])
  end

  def initial_query
    Current.account.applied_slas.includes(:conversation)
  end

  def set_current_page_appiled_slas
    @applied_slas = @applied_slas.page(@current_page).per(RESULTS_PER_PAGE)
  end

  def set_current_page
    @current_page = params[:page] || 1
  end
end
