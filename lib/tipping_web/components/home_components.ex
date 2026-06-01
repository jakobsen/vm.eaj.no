defmodule TippingWeb.HomeComponents do
  @moduledoc """
  Components for use on the landing page.
  """

  use Gettext, backend: TippingWeb.Gettext
  use Phoenix.Component
  use TippingWeb, :verified_routes

  import Phoenix.HTML, only: [raw: 1]

  attr :error_message, :string, default: nil

  def hero(assigns) do
    ~H"""
    <div class={[
      "relative pt-23 px-3 bg-primary-blue text-off-white overflow-hidden",
      "md:px-20 md:pb-30"
    ]}>
      <.hero_top_decoration />
      <.hero_bottom_decoration />
      <div class="relative">
        <div class="max-w-240 mx-auto">
          <h2 class={[
            "text-center leading-none tracking-[7%] text-xl font-bold uppercase mb-15.5",
            "md:text-left"
          ]}>
            {gettext("Fotball-VM 2026")}
          </h2>
          <div class="sm:text-center md:text-left">
            <h1 class={[
              "text-[2rem] tracking-[2%] font-extrabold uppercase mb-6 leading-[1.08]",
              "lg:text-[3.5rem]"
            ]}>
              {raw(gettext("Du vet mer<br />om fotball enn<br />kollegaene dine"))}
            </h1>
            <p class="mb-14">{gettext("Nå gjenstår det bare å bevise det.")}</p>
          </div>
          <div class="grid gap-3">
            <.login_button href={~p"/logg-inn/google"}>
              <.google_logo /> {gettext("Logg inn med %{provider}", provider: "Google")}
            </.login_button>
            <.login_button href={~p"/logg-inn/microsoft"}>
              <.ms_logo /> {gettext("Logg inn med %{provider}", provider: "Microsoft")}
            </.login_button>
            <p class="text-sm font-light opacity-90">
              {gettext("Bruk en bedriftskonto, så finner vi kollegaene dine :)")}
            </p>
          </div>
          <div :if={@error_message} class="font-light text-sm opacity-90 my-5">
            {raw(@error_message)}
          </div>
        </div>
        <div>
          <div class={[
            "w-[305px] absolute -right-3 bottom-6",
            "md:-right-20 md:-bottom-24"
          ]}>
            <img
              class="rounded-tl-full rounded-bl-full"
              src={~p"/images/misunnelig.webp"}
              alt=""
            />
            <div
              data-animate="first"
              class="absolute w-max top-11.5 right-35 text-xl tracking-[1.386px] bg-[#283182] px-2 opacity-0"
            >
              {gettext("Kollegaen din?")}
            </div>
            <.colleague_arrow class="absolute right-28 top-7 opacity-0" />
          </div>
          <div class={[
            "w-[281px] pt-[125px] relative left-1/2 -translate-x-1/2 -bottom-8",
            "md:translate-x-[unset] md:left-[unset] md:absolute md:right-16 md:-bottom-40"
          ]}>
            <img
              src={~p"/images/maradona.webp"}
              alt=""
            />
            <div
              data-animate="second"
              class="opacity-0 absolute w-max top-89 left-64 text-xl tracking-[1.386px] bg-[#283182] px-2"
            >
              {gettext("Deg?")}
            </div>
            <.you_arrow class="opacity-0 absolute left-56.5 top-67.5" />
          </div>
        </div>
      </div>
    </div>
    """
  end

  def about_section(assigns) do
    assigns =
      assigns
      |> assign(
        :wrapper_class,
        ["mb-20 px-2.5 leading-[1.5] tracking-[1%] max-w-240 mx-auto", "lg:text-xl"]
      )
      |> assign(:inner_wrapper_class, "max-w-180")
      |> assign(:header_class, "font-bold text-xl leading-none mb-5")

    ~H"""
    <section class={[@wrapper_class, "pt-42"]}>
      <div class={@inner_wrapper_class}>
        <p class="mb-5">{gettext("Konseptet er enkelt.")}</p>
        <p class="mb-20">
          {gettext("Logg inn med en bedriftskonto, tipp hva resultatet kommer til å bli i VM-kampene,
            og vinn heder og ære.")}
        </p>

        <h2 class="large-heading mb-15">{gettext("Regler")}</h2>
        <ol>
          <.rule number={1}>
            {raw(gettext("Det er resultatet etter 90 minutter +&nbsp;tilleggstid som gjelder."))}
          </.rule>
          <.rule number={2}>
            {gettext("Siste frist for å tippe på en kamp er 10 minutter før avspark.")}
          </.rule>
          <.rule number={3}>{gettext("Poeng beregnes som følger:")}</.rule>
          <.points_table />
          <.rule number={4}>
            {gettext("Å delta er gratis. Premie er som nevnt heder og ære. Eventuelt
            muligheten til å skryte en liten stund. Det får dere avklare internt,
            tenker jeg.")}
          </.rule>
        </ol>
      </div>
    </section>

    <section class={@wrapper_class}>
      <div class={@inner_wrapper_class}>
        <h2 class={@header_class}>{gettext("Litt om personvern og sånn")}</h2>
        <p>
          {raw(
            gettext("Når du logger inn lagrer vi en unik identfikator som vi får fra Google/Microsoft,
          navnet ditt, og domenet til e-posten din (det etter <code>@</code>-tegnet).
          Dette er de tre tingene siden trenger for å fungere, så mer enn det tar
          vi ikke vare på.")
          )}
        </p>
      </div>
    </section>

    <section class={@wrapper_class}>
      <div class={@inner_wrapper_class}>
        <h2 class={@header_class}>{gettext("Noe du vil melde?")}</h2>
        <p>
          {raw(
            gettext(
              "Tilbakemeldinger, spørsmål, ris, ros, varme tanker og blomster kan sendes til <code>post@eaj.no</code>."
            )
          )}
        </p>
      </div>
    </section>
    """
  end

  def footer(assigns) do
    ~H"""
    <footer class="relative bg-primary-blue pt-100 h-[998px]">
      <.footer_top_decoration />
      <.hero_bottom_decoration />

      <h2 class="relative text-xl text-center">
        <span class="font-light">
          {gettext("Laget i Sogndal av")}<br />
        </span>
        <a class="underline hover:no-underline" href="https://dreng.studio">
          dreng.studio
        </a>
      </h2>

      <img
        class="w-[281px] absolute left-1/2 -translate-x-1/2 bottom-0"
        src={~p"/images/maradona.webp"}
        alt=""
      />
    </footer>
    """
  end

  attr :number, :integer
  slot :inner_block

  def rule(assigns) do
    ~H"""
    <li class="flex gap-5 px-2.5 py-5">
      <span class="font-extrabold text-[1.875rem] opacity-20">{@number}</span>
      <span class="min-h-[45px] flex items-center">{render_slot(@inner_block)}</span>
    </li>
    """
  end

  def points_table(assigns) do
    assigns =
      assign(assigns, :class, [
        "py-3 px-5 flex justify-between bg-[#27308366]",
        "first:rounded-tr-[20px]",
        "last:rounded-bl-[20px]"
      ])

    ~H"""
    <ol class="flex flex-col gap-0.5 mb-5">
      <li class={@class}>
        <span>{gettext("Korrekt resultat")}</span>
        <span>3&nbsp;p</span>
      </li>
      <li class={@class}>
        <span>{gettext("Korrekt målforskjell")}</span>
        <span>2&nbsp;p</span>
      </li>
      <li class={@class}>
        <span>{gettext("Korrekt vinner")}</span>
        <span>1&nbsp;p</span>
      </li>
    </ol>
    """
  end

  attr :class, :string, default: nil

  defp colleague_arrow(assigns) do
    ~H"""
    <svg
      data-animate="first"
      xmlns="http://www.w3.org/2000/svg"
      width="66"
      height="14"
      viewBox="0 0 66 14"
      fill="none"
      class={@class}
    >
      <path
        d="M0.381511 10.7693C-0.0496788 11.1054 -0.126801 11.7274 0.209253 12.1586C0.545307 12.5897 1.16728 12.6669 1.59847 12.3308L0.98999 11.5501L0.381511 10.7693ZM64.492 12.5282C65.0322 12.4444 65.4022 11.9385 65.3184 11.3983L63.9527 2.595C63.8689 2.05479 63.363 1.68479 62.8228 1.7686C62.2826 1.8524 61.9126 2.35827 61.9964 2.89849L63.2104 10.7237L55.3852 11.9376C54.845 12.0214 54.475 12.5273 54.5588 13.0675C54.6426 13.6077 55.1484 13.9777 55.6887 13.8939L64.492 12.5282ZM0.98999 11.5501L1.59847 12.3308C11.6228 4.51816 38.1015 -6.41472 63.7559 12.349L64.3402 11.5501L64.9246 10.7511C38.2899 -8.72961 10.8035 2.64679 0.381511 10.7693L0.98999 11.5501Z"
        fill="white"
      />
    </svg>
    """
  end

  attr :class, :string, default: nil

  defp you_arrow(assigns) do
    ~H"""
    <svg
      data-animate="second"
      xmlns="http://www.w3.org/2000/svg"
      width="74"
      height="75"
      viewBox="0 0 74 75"
      fill="none"
      class={@class}
    >
      <path
        d="M72.3408 74.0608C72.2542 74.6005 71.7464 74.9679 71.2066 74.8812C70.6669 74.7946 70.2995 74.2868 70.3862 73.747L71.3635 73.9039L72.3408 74.0608ZM0.444129 9.2481C-0.011953 8.94669 -0.137335 8.33262 0.16407 7.87654L5.0758 0.444275C5.37721 -0.011801 5.99127 -0.137192 6.44736 0.164217C6.90344 0.465626 7.02883 1.07969 6.72742 1.53578L2.36143 8.14223L8.96789 12.5082C9.42397 12.8096 9.54936 13.4237 9.24795 13.8798C8.94654 14.3358 8.33248 14.4612 7.8764 14.1598L0.444129 9.2481ZM71.3635 73.9039L70.3862 73.747C72.5745 60.1129 71.6857 40.6177 62.0973 26.2709C57.32 19.1229 50.3744 13.2353 40.5179 9.96038C30.6471 6.68074 17.794 6.0013 1.18791 9.39213L0.989877 8.42229L0.791845 7.45245C17.6354 4.01316 30.8559 4.664 41.1421 8.08167C51.4426 11.5041 58.7373 17.6808 63.7432 25.1709C73.7209 40.1002 74.5694 60.176 72.3408 74.0608L71.3635 73.9039Z"
        fill="white"
      />
    </svg>
    """
  end

  defp hero_top_decoration(assigns) do
    ~H"""
    <div class="h-[228px] bg-[#212a82] rounded-br-full absolute top-0 left-0 right-0" />
    """
  end

  defp hero_bottom_decoration(assigns) do
    ~H"""
    <div class={[
      "w-[max(100vw,998px)] h-[998px] absolute right-0 bottom-0 rounded-tr-[50%]",
      "bg-linear-to-b from-[#1451ff] to-[#192381]",
      "md:top-0 md:right-43"
    ]} />
    """
  end

  defp footer_top_decoration(assigns) do
    ~H"""
    <div class="h-[228px] bg-dark-blue absolute top-0 left-0 right-0 rounded-br-[50%]" />
    """
  end

  attr :href, :string, required: true
  slot :inner_block, required: true

  defp login_button(assigns) do
    ~H"""
    <a
      href={@href}
      class="max-w-91.5 font-roboto block rounded-full p-0.75 bg-linear-to-r from-white/30 to-[#858585]/30"
    >
      <div class={[
        "py-2.5 px-6 bg-[hsl(226,76%,46%)] rounded-full flex gap-2.5 justify-center items-center",
        "hover:bg-[hsl(226,76%,51%)]"
      ]}>
        {render_slot(@inner_block)}
      </div>
    </a>
    """
  end

  defp ms_logo(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width="20"
      height="20"
      viewBox="0 0 20 20"
    >
      <rect x="0" y="0" width="9" height="9" fill="#f25022" />
      <rect x="0" y="10" width="9" height="9" fill="#00a4ef" />
      <rect x="10" y="0" width="9" height="9" fill="#7fba00" />
      <rect x="10" y="10" width="9" height="9" fill="#ffb900" />
    </svg>
    """
  end

  defp google_logo(assigns) do
    ~H"""
    <svg
      width="20"
      height="20"
      viewBox="0 0 20 20"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <path
        d="M19.6 10.2273C19.6 9.5182 19.5364 8.8364 19.4182 8.1818H10V12.05H15.3818C15.15 13.3 14.4455 14.3591 13.3864 15.0682V17.5773H16.6182C18.5091 15.8364 19.6 13.2727 19.6 10.2273Z"
        fill="#4285F4"
      />
      <path
        d="M10 20C12.7 20 14.9636 19.1045 16.6181 17.5773L13.3863 15.0682C12.4909 15.6682 11.3454 16.0227 10 16.0227C7.3954 16.0227 5.1909 14.2636 4.4045 11.9H1.0636V14.4909C2.7091 17.7591 6.0909 20 10 20Z"
        fill="#34A853"
      />
      <path
        d="M4.4045 11.9C4.2045 11.3 4.0909 10.6591 4.0909 10C4.0909 9.3409 4.2045 8.7 4.4045 8.1V5.5091H1.0636C0.3864 6.8591 0 8.3864 0 10C0 11.6136 0.3864 13.1409 1.0636 14.4909L4.4045 11.9Z"
        fill="#FBBC04"
      />
      <path
        d="M10 3.9773C11.4681 3.9773 12.7863 4.4818 13.8227 5.4727L16.6909 2.6045C14.9591 0.9909 12.6954 0 10 0C6.0909 0 2.7091 2.2409 1.0636 5.5091L4.4045 8.1C5.1909 5.7364 7.3954 3.9773 10 3.9773Z"
        fill="#E94235"
      />
    </svg>
    """
  end
end
