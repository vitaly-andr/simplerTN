class TestsController < Simpler::Controller

  def index
    @time = Time.now
    @tests = Test.all
    render :list

  end

  def create

  end

end
