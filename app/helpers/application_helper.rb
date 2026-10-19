module ApplicationHelper
  # The production origin, not the request's: there is no config.hosts, so a
  # forged Host header must not reach the canonical link.
  CANONICAL_ORIGIN = "https://onset.joaotorr.es"

  # SPEC.md §8, Search engines: only the public pages carry one.
  def canonical_link(path)
    tag.link(rel: "canonical", href: "#{CANONICAL_ORIGIN}#{path}")
  end
end
