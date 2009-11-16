class Bayes
  class << self
    # Add class to classes set
    def add_class(klass)
      Ohm.redis.sadd("classes", klass)
    end
    # Get defined classes
    def get_classes
      Ohm.redis.smembers("classes")
    end
    def train(klass, text)
      words(text).each do |word|
        Ohm.redis.incr "#{klass}:#{word}"
      end
      Ohm.redis.incr "#{klass}"
      Ohm.redis.incr "total_texts"
    end
    def classify(text)
      scores = {}
      get_classes.each do |klass|
        scores[klass] = (prob_of_text_given_a_class(text, klass) * prob_of_class(klass))
      end
      scores.sort {|a, b| b[1] <=> a[1]}[0]
    end
    def prob_of_text_given_a_class(text, klass)
      words(text).inject(1.0) do |sum, word|
        prob = prob_of_word_given_a_class(word, klass)
        prob = assumed_probability if prob == 0
        sum *= prob
      end
    end
    def prob_of_word_given_a_class(word, klass)
      class_count = Ohm.redis.get("#{klass}").to_f
      return 0.5 if class_count == 0.0
      class_word_count = Ohm.redis.get("#{klass}:#{word}").to_f
      class_word_count / class_count
    end
    def prob_of_class(klass)
      class_count = Ohm.redis.get("#{klass}").to_f
      class_count / total_texts
    end
    def total_texts
      Ohm.redis.get("total_texts").to_f
    end
    def assumed_probability
      0.5 / (total_texts / 2.0)
    end
    def words(text)
      text.gsub(/[^\w\s]/, ' ').downcase.split(' ')
    end
  end
end