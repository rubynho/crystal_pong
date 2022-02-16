require "crsfml"

require "./entities/racket.cr"

#################################
# Pong game built with Crystal. #
#################################

module CrystalPong
  VERSION = "0.1.0"

  WINDOW_WIDTH       = 1000
  WINDOW_HEIGHT      =  600
  WINDOW_HEIGHT_HALF = WINDOW_HEIGHT * 0.5
  WINDOW_WIDTH_HALF  = WINDOW_WIDTH * 0.5

  RACKET_WIDTH       =  20.0
  RACKET_HEIGHT      = 125.0
  RACKET_WIDTH_HALF  = RACKET_WIDTH * 0.5
  RACKET_HEIGHT_HALF = RACKET_HEIGHT * 0.5
  RACKET_PADDING     = 50

  BALL_SIZE   =    20
  BALL_SPEED  = 240.0
  BALL_RADIUS = BALL_SIZE * 0.5

  PLAYER_SPEED = 400

  CENTER_LINE_THICKNESS = 3

  window = SF::RenderWindow.new(SF::VideoMode.new(WINDOW_WIDTH, WINDOW_HEIGHT), "Crystal Pong")

  left_racket = Entities::Racket.new
  right_racket = Entities::Racket.new

  left_racket.position = SF.vector2(RACKET_PADDING, WINDOW_HEIGHT_HALF - RACKET_HEIGHT_HALF)
  right_racket.position = SF.vector2(WINDOW_WIDTH - RACKET_WIDTH - RACKET_PADDING, WINDOW_HEIGHT_HALF - RACKET_HEIGHT_HALF)

  struct MainState
    getter ball_pos : Tuple(Int32, Int32)
    property ball_vel : SF::Vector2(Float64)

    property player_1_score : Int32
    property player_2_score : Int32

    def initialize
      @ball_pos = {WINDOW_WIDTH_HALF.to_i, (WINDOW_HEIGHT_HALF - BALL_RADIUS).to_i}
      @ball_vel = randomize_vec(SF::Vector2.new(0.0, 0.0), BALL_SPEED, BALL_SPEED)

      @player_1_score = 0
      @player_2_score = 0
    end

    def randomize_vec(vec : SF::Vector2(Float64), x : Float64, y : Float64)
      vec = SF::Vector2.new([-x, x].shuffle.first, [-y, y].shuffle.first)
    end

    def reset_ball(ball)
      ball.position = @ball_pos
      @ball_vel = randomize_vec(SF::Vector2.new(0.0, 0.0), BALL_SPEED, BALL_SPEED)
    end
  end

  main_state = MainState.new

  clock = SF::Clock.new

  ball = SF::RectangleShape.new(SF.vector2(BALL_SIZE, BALL_SIZE))

  font = SF::Font.from_file("assets/alterebro-pixel-font.ttf")
  scoreboard = SF::Text.new("#{main_state.player_1_score}      #{main_state.player_2_score}", font, 60)
  scoreboard.color = SF::Color::White
  scoreboard_width_half = scoreboard.local_bounds.width * 0.5
  scoreboard.position = SF.vector2(WINDOW_WIDTH_HALF - scoreboard_width_half, 0.0)

  ball.position = main_state.ball_pos

  center_line = SF::RectangleShape.new(SF.vector2(CENTER_LINE_THICKNESS, WINDOW_HEIGHT))
  center_line.position = SF.vector2(WINDOW_WIDTH_HALF.to_f32 - CENTER_LINE_THICKNESS * 0.5, 0.0)

  while window.open?
    dt = clock.restart.as_seconds

    while event = window.poll_event
      if event.is_a? SF::Event::Closed ||
         (event.is_a? SF::Event::KeyPressed && event.code.escape?)
        window.close
      end
    end

    window.clear

    left_racket.move(0.0, -PLAYER_SPEED * dt) if SF::Keyboard.key_pressed?(SF::Keyboard::W)
    left_racket.move(0.0, PLAYER_SPEED * dt) if SF::Keyboard.key_pressed?(SF::Keyboard::S)
    right_racket.move(0.0, -PLAYER_SPEED * dt) if SF::Keyboard.key_pressed?(SF::Keyboard::Up)
    right_racket.move(0.0, PLAYER_SPEED * dt) if SF::Keyboard.key_pressed?(SF::Keyboard::Down)

    ball.position += main_state.ball_vel * dt

    # score count
    if ball.position.x < 0.0
      main_state.reset_ball(ball)
      main_state.player_2_score += 1
    elsif ball.position.x > WINDOW_WIDTH - BALL_SIZE
      main_state.reset_ball(ball)
      main_state.player_1_score += 1
    end

    if ball.position.y < 0.0
      ball.position.y = BALL_SIZE.to_f32
      main_state.ball_vel.y = main_state.ball_vel.y.abs
    elsif ball.position.y > WINDOW_HEIGHT - BALL_SIZE
      ball.position.y = WINDOW_HEIGHT.to_f32
      main_state.ball_vel.y = -main_state.ball_vel.y.abs
    end

    if left_racket.collides?(ball)
      main_state.ball_vel.x = main_state.ball_vel.y.abs
    elsif right_racket.collides?(ball)
      main_state.ball_vel.x = -main_state.ball_vel.y.abs
    end

    scoreboard.string = "#{main_state.player_1_score}      #{main_state.player_2_score}"

    window.draw(left_racket)
    window.draw(right_racket)
    window.draw(ball)
    window.draw(scoreboard)
    window.draw(center_line)

    window.display
  end
end
