class Main
  get "/" do
    haml :home
  end
  get "/train" do
    haml :train, :classes => Bayes.get_classes
  end
  post '/train' do
    klass = params[:klass]
    Bayes.add_class(klass)
    Bayes.train(klass, params[:text])
    
    "Rebayes knows something more about #{klass}: #{Ohm.redis.get klass}"
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
