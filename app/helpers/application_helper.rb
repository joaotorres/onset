module ApplicationHelper
  # The production origin, not the request's: there is no config.hosts, so a
  # forged Host header must not reach the canonical link.
  CANONICAL_ORIGIN = "https://onset.joaotorr.es"

  # SPEC.md §8, Search engines: only the public pages carry one.
  def canonical_link(path)
    tag.link(rel: "canonical", href: "#{CANONICAL_ORIGIN}#{path}")
  end

  # SPEC.md §7, Screens ignore broadcasts older than what they show: the newest
  # updated_at among loaded records, as integer microseconds (a float drops digits).
  def stream_version(*records)
    records.map { |record| (record.updated_at.to_r * 1_000_000).to_i }.max
  end
end
