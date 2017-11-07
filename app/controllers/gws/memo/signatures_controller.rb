class Gws::Memo::SignaturesController < ApplicationController
  include Gws::BaseFilter
  include Gws::CrudFilter

  model Gws::Memo::Signature

  private

  def set_crumbs
    @crumbs << [t('mongoid.models.gws/memo/message'), gws_memo_messages_path ]
    @crumbs << [t('mongoid.models.gws/memo/signature'), gws_memo_signatures_path ]
  end

  def fix_params
    { cur_user: @cur_user, cur_site: @cur_site }
  end

end