class TestsController < Simpler::Controller

  def index
    @time = Time.now
    @tests = Test.all
    status HTTP_STATUS_OK
    header 'X-Simpler-Action', 'Index'

    # render :list

  end

  def create
    @time = Time.now
    @tests = Test.all
    status HTTP_STATUS_CREATED
    header 'X-Simpler-Action', 'Create'
  end

  def show
    @test = Test.where(id: params[:id].to_i).first #метод find выдавал ошибку и сделал так
  end

end
