# frozen_string_literal: true
class TheUsersController < ApplicationController

  skip_before_action :check_user_have_email

  def show_complete_email_page
  end

  def complete_email
    email = params[:email]

    # 如果该用户存在的话，
    user = User.where('email = ?', params[:email]).first

    if user.present?
      unless user.valid_password? params[:password_for_exitsing_email]
        redirect_back fallback_location: root_url, alert: '操作失败：密码不正确.' and return
      end
      if user.wallet_type.present?
        redirect_back fallback_location: root_url, alert: '操作失败：该Email对应的账户已经绑定了Web3钱包'
      else
        user.wallet_type = current_user.wallet_type
        user.eth_address = current_user.eth_address
        user.polka_address = current_user.polka_address
        user.save!

        # 退出，删掉 web3注册的临时账户
        sign_out current_user
        current_user.delete

        # 绑定 对应的user
        sign_in user

        redirect_to root_path, notice: '操作成功，您的账户已经成功原有论坛账户'
      end

    # 如果该email不存在，则update 对应用户的email
    else

      if params[:password] != params[:password2]
        redirect_back fallback_location: root_url, alert: '操作失败：两次密码不一致' and return
      end

      if User.where('login = ?', params[:login]).first.present?
        redirect_back fallback_location: root_url, alert: '操作失败：login已经存在' and return
      end

      user_id = current_user.id
      sign_out current_user

      sql = "update users set email = '#{params[:email]}' where id = #{user_id}"
      sanitized_sql = ActiveRecord::Base.sanitize_sql(sql)
      ActiveRecord::Base.connection.execute(sanitized_sql)
      # 休息一秒，不要弄的太快。
      sleep 0.1
      user = User.find user_id
      user.password = params[:password]
      user.login = params[:login]
      user.save!

      sign_in user

      redirect_to root_path, notice: '操作成功，您的账户已经成功绑定Email'
    end
  end

  def is_email_existing
    user = User.where('email = ?', params[:email]).first
    render json: {
      result: user.present?
    }
  end
end
