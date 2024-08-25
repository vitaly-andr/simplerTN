class TestsController < Simpler::Controller

  def index
    @time = Time.now
    @tests = Test.all
    render plain: "This is plain text"

  end

  def create

  end

end
