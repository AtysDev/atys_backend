defmodule Auth.Email do
  @one_day 24 * 60 * 60 * 1000
  @one_hour 60 * 60 * 1000

  def confirm_email_address(email: email, id: id) do
    token = create_token()
    Sider.set(:email_tokens, token, id, @one_day)

    email_body =
      """
      Hello! Welcome to Atys. Please confirm your email by going to atys.dev/confirm and pasting in the token below:

      #{token}
      """ <> register_footer()

    send_email(email, email_body)
  end

  def trying_to_reregister(email) do
    email_body =
      """
      Hello! You've tried to create a new account at Atys. However, our records indicate that you have already created an account with us.
      Please go to https://atys.dev/login and fill in your username and password to continue. If you've forgotten your password,
      you can click on the forgot password link from the login page.
      """ <> register_footer()

    send_email(email, email_body)
  end

  def reset_password(email: email, id: id) do
    token = create_token()
    Sider.set(:email_tokens, token, id, @one_hour)

    email_body =
      """
        Hello! To reset your password, please go to https://atys.dev/reset and pasting in the token below:

        #{token}

      This token expires in one hour.
      """ <>
        thanks() <>
        "You are receiving this email because someone (hopefully you!) tried to reset your password." <>
        "If this is not the case, or you now remember your password, simply delete this email. Replies to this email are not monitored." <>
        clickable_reminder()

    send_email(email, email_body)
  end

  defp send_email(email, body) do
    email_provider = Application.get_env(:auth, :email_provider)
    apply(email_provider, :send, [[email: email, body: body]])
  end

  defp create_token() do
    prefix = System.unique_integer([:positive])
    secure_token = :crypto.strong_rand_bytes(32)
    (<<prefix>> <> secure_token) |> Base.url_encode64()
  end

  defp thanks() do
    """

    Thanks!
    Your friends at Atys


    """
  end

  defp register_footer() do
    thanks() <>
      """
      You are receiving this email because someone (hopefully you!) tried to register an account at https://atys.dev
      If you did not request an account, or you changed your mind, you can simply delete this email. Replies to this email are not monitored.
      """ <> clickable_reminder()
  end

  defp clickable_reminder() do
    """

    As a reminder: We will never send you clickable URL's via email. If you ever receive an email from atys.dev which asks you to click a link, please disregard the message.
    """
  end
end
