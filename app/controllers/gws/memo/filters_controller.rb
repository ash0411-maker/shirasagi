class Gws::Memo::FiltersController < ApplicationController
  include Gws::BaseFilter
  include Gws::CrudFilter

  model Gws::Memo::Filter

  def set_crumbs
    @crumbs << [t('mongoid.models.gws/memo/message'), gws_memo_messages_path ]
    @crumbs << [t('mongoid.models.gws/memo/folder'), gws_memo_filters_path ]
  end

  def fix_params
    { cur_user: @cur_user, cur_site: @cur_site }
  end

end