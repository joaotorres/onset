# Shared by the locked_entry_*_spec.rb files in spec/system/player_screen_theme/:
# a locked entry on the player screen's scoreboard (SPEC §10 Visual system, Text).
RSpec.shared_context "locked entry" do
  include_context "player screen theme"
  include_context "dark contrast"
  include_context "player screen with 8 players and 18 cards", 375, 667

  let(:sizes) { [[375, 667], [667, 375], [1280, 800]] }
  let(:own_name) { me.name }
  let(:locked_other) { game.players.where.not(id: [me.id, other.id]).find(&:locked?) }

  # The WCAG contrast ratio of the element's computed color on the computed
  # background of its entry li. Colors go through a canvas, so any CSS color
  # syntax (rgb, oklch) lands as the sRGB bytes it paints.
  def contrast_on_entry(element)
    page.evaluate_script(<<~JS, element)
      ((el) => {
        const ctx = document.createElement("canvas").getContext("2d", {willReadFrequently: true})
        const srgb = (css) => {
          ctx.clearRect(0, 0, 1, 1)
          ctx.fillStyle = css
          ctx.fillRect(0, 0, 1, 1)
          return [...ctx.getImageData(0, 0, 1, 1).data.slice(0, 3)]
        }
        const lum = (rgb) => {
          const [r, g, b] = rgb.map(v => { v /= 255; return v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4 })
          return 0.2126 * r + 0.7152 * g + 0.0722 * b
        }
        const fg = lum(srgb(getComputedStyle(el).color))
        const bg = lum(srgb(getComputedStyle(el.closest("li")).backgroundColor))
        return (Math.max(fg, bg) + 0.05) / (Math.min(fg, bg) + 0.05)
      })(arguments[0])
    JS
  end

  # The lowest computed opacity from the element up to its entry li, both included.
  def lowest_opacity_to_entry(element)
    page.evaluate_script(<<~JS, element)
      ((el) => {
        let low = 1
        for (let n = el; n; n = n.parentElement) {
          low = Math.min(low, parseFloat(getComputedStyle(n).opacity))
          if (n.tagName === "LI") break
        }
        return low
      })(arguments[0])
    JS
  end

  def entry(name) = find("[data-scoreboard] li", text: name)

  def lock_both!
    me.update!(locked_until: 5.seconds.from_now)
    locked_other.update!(locked_until: 5.seconds.from_now)
  end

  # Every size: the locked name and score of both entries read at 4.5:1 or
  # more, unfaded, the dot faded, the Locked tag as before; an unlocked entry
  # stays at full opacity with its plain color.
  def expect_locked_entries(plain:, own:)
    lock_both!
    sizes.each do |width, height|
      resize(width, height)
      visit game_controller_path(game.code)
      at = "#{width}x#{height}"
      [[locked_other.name, plain], [own_name, own]].each do |name, name_color|
        li = entry(name)
        expect(li).to have_css("[data-locked-tag]", text: /locked/i)
        tag = li.find("[data-locked-tag]")
        expect(style_of(tag, "background-color")).to eq(color("red-600")), at
        expect(style_of(tag, "color")).to eq(color("white")), at
        [li.find("[data-name]"), li.find("[data-score]")].each do |text|
          expect(contrast_on_entry(text)).to be >= 4.5, "#{name} at #{at}"
          expect(lowest_opacity_to_entry(text)).to eq(1), "#{name} at #{at}"
        end
        expect(style_of(li.find("[data-name]"), "color")).to eq(name_color), "#{name} at #{at}"
        expect(style_of(li.find("[data-entry-content] > span:first-child"), "opacity")).to eq("0.45"), at
      end
      plain_entry = entry(other.name)
      expect(plain_entry).to have_no_css("[data-locked-tag]")
      expect(lowest_opacity_to_entry(plain_entry.find("[data-name]"))).to eq(1), at
      expect(style_of(plain_entry.find("[data-name]"), "color")).to eq(style_of(plain_entry, "color")), at
      expect(style_of(plain_entry.find("[data-entry-content] > span:first-child"), "opacity")).to eq("1"), at
    end
  end
end
