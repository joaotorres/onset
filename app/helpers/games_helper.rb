module GamesHelper
  def join_qr_svg(game, size_class)
    RQRCode::QRCode.new(join_game_players_url(game.code)).as_svg(
      offset: 0, color: "030712", shape_rendering: "crispEdges",
      module_size: 4, standalone: true, use_path: true,
      viewbox: true, svg_attributes: {class: "block #{size_class}"}
    ).html_safe
  end

  # "onset.joaotorr.es" or "localhost:3000": the room code does the rest.
  def join_host
    uri = URI(root_url)
    (uri.port == uri.default_port) ? uri.host : "#{uri.host}:#{uri.port}"
  end
end
