class Main
  get "/" do
    @classes = Bayes.get_classes
    haml :home
  end
  get "/train" do
    haml :train
  end
  get "/train/:klass" do
    @klass = params[:klass]
    haml :train
  end
  post '/train' do
    klass = params[:klass]
    Bayes.add_class(klass)
    Bayes.train(klass, params[:text])
    
    redirect "/train_success/#{klass}"
  end
  get '/train_success/:klass' do
    @klass = params[:klass]
    @klass_count = Ohm.redis.get @klass

    haml :train_success
  end
  get '/classify' do
    haml :classify
  end
  post '/classify' do
    text = params[:text]
    @classification = Bayes.classify(text)
    
    haml :classify
  end
end
