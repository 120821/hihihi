# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  before_action :require_no_sso!, only: %i[new create]
  skip_before_action :check_user_have_email

  # 目前的逻辑： 如果对应的ETH地址存在的话，就登录该用户
  # 期望的逻辑： 第1步先是用以太坊钱包注册了一个账户(简称账户a)，
  # 第2步如果没有邮箱，需要绑定邮箱信息到账户a，
  # 第3步如果绑定一个已经存在账户b的邮件的地址，那就把以太坊钱包写到账户b，这个新的账户a删掉，a是临时账户，没有任何帖子
  # 验证原来的账号只需要填写密码
  def create
    wallet_type = params[:wallet_type]

    # web3的登录逻辑
    if wallet_type.present? && wallet_type.in?(User::SUPPORTED_WALLET_TYPES)
      address_column = "#{wallet_type}_address"
      user = User.where("#{address_column} = ?", params[:address]).first

      Rails.logger.info "== user login with #{wallet_type}, user: #{user.inspect}"
      # 如果用户存在的话，直接登录
      if user.present?
        sign_in user
        # 如果email不存在的话，要求补齐email
        if user.email.include? "noemail"
          redirect_to show_complete_email_page_the_users_path, notice: 'Sign in successfully'

        # 如果email存在的话，直接登录
        else
          redirect_back_or_default(root_url)
        end

      # 如果该用户不存在的话，直接注册
      else
        # 先检查IP 限制
        cache_key = ["user-sign-up", request.remote_ip, Date.today]
        sign_up_count = Rails.cache.read(cache_key) || 0
        setting_limit = Setting.sign_up_daily_limit
        if setting_limit > 0 && sign_up_count >= setting_limit
          message = "You not allow to sign up new Account, because your IP #{request.remote_ip} has over #{setting_limit} times in today."
          logger.warn message
          return render status: 403, plain: message
        end

        # 如果没问题的话，则开始注册
        user = User.create email: "#{params[:address]}@noemail.com",
          wallet_type: params[:wallet_type],
          address_column.to_sym => params[:address],
          name: params[:address][0..8],
          login: params[:address][0..8]
        puts "== user.name: #{user.name}"
        user.password = params[:address] + Time.now.to_s
        user.save!
        sign_in user

        # 设置该IP注册的用户数量
        Rails.cache.write(cache_key, sign_up_count + 1)

        redirect_to show_complete_email_page_the_users_path, notice: 'Sign in successfully'
      end

    # 传统的登录逻辑
    else
      resource = warden.authenticate!(auth_options)
      set_flash_message(:notice, :signed_in) if is_navigational_format?

      if session[:omniauth]
        @auth = Authorization.find_or_create_by!(provider: session[:omniauth]["provider"], uid: session[:omniauth]["uid"], user_id: resource.id)
        if @auth.blank?
          redirect_to new_user_session_path, alert: "Sign in failed."
          return
        end

        set_flash_message(:notice, "Sign in successfully with bind #{Homeland::Utils.omniauth_name(session[:omniauth]["provider"])}")
        session[:omniauth] = nil
      end

      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_to do |format|
        format.html { redirect_back_or_default(root_url) }
        format.json { render status: "201", json: resource.as_json(only: %i[login email]) }
      end
    end
  end
end
