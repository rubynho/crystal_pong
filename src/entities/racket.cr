class CrystalPong::Entities::Racket < SF::Transformable
  include SF::Drawable

  def initialize
    super()

    @shape = SF::RectangleShape.new(SF.vector2(RACKET_WIDTH, RACKET_HEIGHT))
  end

  def collides?(entity : SF::Shape)
    global_bounds.intersects?(entity.global_bounds)
  end

  private def local_bounds
    @shape.local_bounds
  end

  private def global_bounds
    self.transform.transform_rect(local_bounds())
  end

  def move(x, y)
    super(x, y)

    limit_movement()
  end

  # Limits the racket to pass the window boundaries (up and down).
  private def limit_movement
    low = 0.0
    high = (WINDOW_HEIGHT - RACKET_HEIGHT).to_f

    if self.position.y < low
      self.position = {self.position.x, low}
    elsif self.position.y > high
      self.position = {self.position.x, high}
    end
  end

  def draw(target, states)
    states.transform *= self.transform

    target.draw(@shape, states)
  end
end
