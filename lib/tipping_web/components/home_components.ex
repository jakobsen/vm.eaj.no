defmodule TippingWeb.HomeComponents do
  use Phoenix.Component
  use TippingWeb, :verified_routes

  def hero(assigns) do
    ~H"""
    <div class="relative pt-23 px-3 bg-primary-blue text-off-white overflow-hidden">
      <.hero_top_decoration />
      <.hero_bottom_deocration />
      <div class="relative">
        <h2 class="text-center text-xl font-bold uppercase mb-15.5">Fotball-VM 2026</h2>
        <h1 class="text-[2rem] font-extrabold uppercase mb-12">
          Du vet mer<br />om fotball enn<br />kollegaene dine
        </h1>
        <p class="mb-8.5">Nå gjenstår det bare å bevise det.</p>
        <.sign_in_with_google />
        <div>
          <img
            class="w-[305px] rounded-tl-full rounded-bl-full absolute -right-3 bottom-6"
            src={~p"/images/misunnelig.webp"}
            alt=""
          />
          <img
            class="w-[281px] pt-[125px] relative left-1/2 -translate-x-1/2 -bottom-8"
            src={~p"/images/maradona.webp"}
            alt=""
          />
        </div>
      </div>
    </div>
    """
  end

  defp hero_top_decoration(assigns) do
    ~H"""
    <div class="h-[230px] w-screen bg-[#212a82] rounded-br-[50%] absolute top-0 left-0" />
    """
  end

  defp hero_bottom_deocration(assigns) do
    ~H"""
    <div class={[
      "size-[max(100vw,998px)] bg-red-300 absolute right-0 bottom-0 rounded-tr-[50%]",
      "bg-linear-to-b from-[#1451ff] to-[#192381]"
    ]} />
    """
  end

  defp sign_in_with_google(assigns) do
    ~H"""
    <div
      id="g_id_onload"
      data-client_id="54992027643-991u17tde1r2fk9g2mvv2ei4cn25cklm.apps.googleusercontent.com"
      data-login_uri={url(~p"/auth-callback")}
      data-auto_prompt="false"
      data-hd="*"
    >
    </div>
    <div
      class="g_id_signin bg-transparent mx-auto flex justify-center"
      data-type="standard"
      data-size="large"
      data-theme="filled_blue"
      data-width="350"
      data-locale="no_"
      data-text="sign_in_with"
      data-shape="pill"
      data-logo_alignment="left"
    >
    </div>
    """
  end
end
