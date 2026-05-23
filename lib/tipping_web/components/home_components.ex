defmodule TippingWeb.HomeComponents do
  use Phoenix.Component
  use TippingWeb, :verified_routes

  def hero(assigns) do
    ~H"""
    <div class="relative pt-23 px-3 bg-primary-blue text-off-white overflow-hidden">
      <.hero_top_decoration />
      <.hero_bottom_decoration />
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

  def about_section(assigns) do
    assigns =
      assigns
      |> assign(
        :wrapper_class,
        "mb-20 px-2.5 leading-[1.5] tracking-[1%]"
      )
      |> assign(:header_class, "font-bold text-xl leading-none mb-5")

    ~H"""
    <section class={[@wrapper_class, "pt-42"]}>
      <p class="mb-5">Konseptet er enkelt.</p>
      <p class="mb-20">
        Logg inn med en bedriftskonto, legg inn hva resultatet kommer til å bli i VM-kampene,
        og vinn heder og ære.
      </p>

      <h2 class="large-heading mb-15">Regler</h2>
      <ol>
        <.rule number={1}>Siste frist for å tippe på en kamp er 10 minutter før avspark.</.rule>
        <.rule number={2}>Poeng beregnes som følger:</.rule>
        <.points_table />
        <.rule number={3}>
          Å delta er gratis. Premie er som nevnt heder og ære. Eventuelt
          muligheten til å skryte en liten stund. Det får dere avklare internt,
          tenker jeg.
        </.rule>
      </ol>
    </section>

    <section class={@wrapper_class}>
      <h2 class={@header_class}>Litt om personvern og sånn</h2>
      <p>
        Når du logger inn lagrer vi en unik identfikator som vi får fra Google,
        navnet ditt, og domenet til e-posten din (det etter <code>@</code>-tegnet).
        Dette er de tre tingene siden trenger for å fungere, så mer enn det tar
        vi ikke vare på.
      </p>
    </section>

    <section class={@wrapper_class}>
      <h2 class={@header_class}>Noe du vil melde?</h2>
      <p>
        Tilbakemeldinger, spørsmål, ris, ros, varme tanker og blomster kan sendes til <code>post@eaj.no</code>.
      </p>
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
          Laget i Sogndal av<br />
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

  defp rule(assigns) do
    ~H"""
    <li class="flex gap-5 px-2.5 py-5">
      <span class="font-extrabold text-[1.875rem] opacity-20">{@number}</span>
      <span class="min-h-[45px] flex items-center">{render_slot(@inner_block)}</span>
    </li>
    """
  end

  defp points_table(assigns) do
    assigns =
      assign(assigns, :class, [
        "py-3 px-5 flex justify-between bg-[#27308366]",
        "first:rounded-tr-[20px]",
        "last:rounded-bl-[20px]"
      ])

    ~H"""
    <ol class="flex flex-col gap-0.5">
      <li class={@class}>
        <span>Korrekt resultat</span>
        <span>3&nbsp;p</span>
      </li>
      <li class={@class}>
        <span>Korrekt målforskjell</span>
        <span>2&nbsp;p</span>
      </li>
      <li class={@class}>
        <span>Korrekt vinner</span>
        <span>1&nbsp;p</span>
      </li>
    </ol>
    """
  end

  defp hero_top_decoration(assigns) do
    ~H"""
    <div class="h-[228px] w-screen bg-[#212a82] rounded-br-full absolute top-0 left-0" />
    """
  end

  defp hero_bottom_decoration(assigns) do
    ~H"""
    <div class={[
      "size-[max(100vw,998px)] bg-red-300 absolute right-0 bottom-0 rounded-tr-[50%]",
      "bg-linear-to-b from-[#1451ff] to-[#192381]"
    ]} />
    """
  end

  defp footer_top_decoration(assigns) do
    ~H"""
    <div class="h-[228px] w-screen bg-dark-blue absolute top-0 left-0 rounded-br-[50%]" />
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
