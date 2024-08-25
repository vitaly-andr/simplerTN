class TestsController < Simpler::Controller

  def index
    @time = Time.now
    @tests = Test.all
    status HTTP_STATUS_OK
    header 'X-Simpler-Action', 'Index'

    render :list

  end

  def create

  end

end
