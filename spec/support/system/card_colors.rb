# Shared by spec/system/card_colors/: the two card palettes and the color
# mark (SPEC §10 Palette, DESIGN v6 cards/_card).
RSpec.shared_context "card colors" do
  include_context "settings menu"

  def rgb(hex) = "rgb(#{hex.delete("#").scan(/../).map { |h| h.to_i(16) }.join(", ")})"

  def classic = %w[#C1121F #198A1E #5E2CA5].map { |h| rgb(h) }
  def colorblind = %w[#648FFF #FE6100 #DC267F].map { |h| rgb(h) }

  def colorblind!
    page.driver.browser.manage.add_cookie(name: "card_colors", value: "colorblind", path: "/")
  end

  def light!
    theme_cookie!("light")
  end

  def card_colors_cookie
    page.driver.browser.manage.all_cookies.find { |c| c[:name] == "card_colors" }
  end

  # Per card color in scope: the computed colors of every shape's stroke, solid
  # fill and hatch line, and of every color mark shown (nil for a hidden one).
  def card_paint(scope)
    page.evaluate_script(<<~JS)
      (() => {
        const out = {}
        document.querySelectorAll(#{"#{scope} svg[class*=card-c]".to_json}).forEach(svg => {
          const color = [...svg.classList].find(c => c.startsWith("card-c"))
          const o = out[color] ||= {colors: [], marks: [], count: 0}
          o.count++
          svg.querySelectorAll(".card-shape").forEach(s => {
            const st = getComputedStyle(s)
            o.colors.push(st.stroke)
            if (!st.fill.startsWith("url") && st.fill !== "none") o.colors.push(st.fill)
          })
          svg.querySelectorAll("pattern rect").forEach(r => o.colors.push(getComputedStyle(r).fill))
          svg.querySelectorAll(".color-mark").forEach(m => {
            const st = getComputedStyle(m)
            o.marks.push(st.display === "none" ? null : st.fill)
          })
          o.markCount = (o.markCount || 0) + svg.querySelectorAll(".color-mark").length
        })
        Object.values(out).forEach(o => { o.colors = [...new Set(o.colors)]; o.marks = [...new Set(o.marks)] })
        return out
      })()
    JS
  end

  # Every card in scope paints in the palette and shows its marks or none.
  # colors: which card colors must be present.
  def expect_cards(scope, palette, marks:, colors: [0, 1, 2])
    paint = card_paint(scope)
    expect(paint.keys.sort).to eq(colors.map { |c| "card-c#{c}" }), "#{scope}: #{paint.keys}"
    colors.each do |c|
      group = paint["card-c#{c}"]
      expect(group["colors"]).to eq([palette[c]]), "#{scope} color #{c}: #{group["colors"]}"
      expect(group["markCount"]).to eq(group["count"] * 2), "#{scope} color #{c} mark count"
      expect(group["marks"]).to eq([marks ? palette[c] : nil]), "#{scope} color #{c} marks"
    end
  end
end
