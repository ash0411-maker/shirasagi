class Gws::Affair::Overtime::Management::AggregateController < ApplicationController
  include Gws::BaseFilter
  include Gws::CrudFilter

  model Gws::Affair::OvertimeDayResult

  navi_view "gws/affair/main/navi"
  menu_view nil

  before_action :set_query

  private

  def set_query
    @current = Time.zone.now

    # TODO manage_all or manage_private
    @groups = Gws::Group.in_group(@cur_site).active

    @year = (params.dig(:s, :year).presence || @current.year).to_i
    @month = (params.dig(:s, :month).presence || @current.month).to_i
    @group_id = params.dig(:s, :group_id)
    @capital_id = params.dig(:s, :capital_id)
  end

  def set_items
    @threshold = params[:threshold]

    start_at = Time.zone.parse("#{@year}/#{@month}/1").to_date
    end_at = start_at.end_of_month

    if @group_id.present?
      group_ids = @groups.where(id: @group_id).pluck(:id)
    else
      group_ids = @groups.pluck(:id)
    end
    @users = Gws::User.active.in(group_ids: group_ids).order_by_title(@cur_site)
    user_ids = @users.pluck(:id)

    cond = [
      { "date" => { "$gte" => start_at } },
      { "date" => { "$lte" => end_at } },
      { "user_id" => { "$in" => user_ids } }
    ]

    if @capital_id.present?
      cond << { "capital_id" => @capital_id.to_i }
    end

    @items = @model.site(@cur_site).and(cond)
  end

  def set_time_cards
    @unlocked_time_cards = []
    date = DateTime.new(@year, @month, 1, 0, 0, 0).to_date
    @users.each do |user|
      title = I18n.t('gws/attendance.formats.time_card_full_name',
        user_name: user.name, month: I18n.l(date, format: :attendance_year_month)
      )
      time_card = Gws::Attendance::TimeCard.site(@cur_site).user(user).where(date: date).first
      if !time_card || !time_card.locked?
        @unlocked_time_cards << title
      end
    end
  end

  public

  def index
    set_items
    set_time_cards
    @items = @items.aggregate_by_user
  end

  def download
    return if request.get?

    safe_params = params.require(:item).permit(:encoding)
    encoding = safe_params[:encoding]
    filename = "aggregate_#{@threshold}_#{Time.zone.now.to_i}.csv"

    set_items
    enum_csv = @items.enum_csv(@users, @threshold, OpenStruct.new(encoding: encoding))
    send_enum(enum_csv, type: "text/csv; charset=#{encoding}", filename: filename)
  end
end
