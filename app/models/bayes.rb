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
      total_texts = Ohm.redis.get("total_texts").to_f
      for klass in get_classes
        class_count = Ohm.redis.get("#{klass}").to_f
        scores[klass] = (prob_of_text_given_a_class(text, klass, class_count, total_texts) * prob_of_class(klass, class_count, total_texts))
      end
      scores.sort {|a, b| b[1] <=> a[1]}[0]
    end
    def prob_of_text_given_a_class(text, klass, class_count, total_texts)
      word_counts = Ohm.redis.mget(words(text).map{|word| "#{klass}:#{word}"}).map(&:to_f)
      word_counts.inject(1.0) do |sum, word_count|
        prob = class_count == 0 ? 0.5 : word_count / class_count
        prob = 0.5 / (total_texts / 2.0) if prob == 0
        sum *= prob
      end
    end
    def prob_of_class(klass, class_count, total_texts)
      class_count / total_texts
    end
    def words(text)
      text.gsub(/[^\w\s]/, ' ').downcase.split(' ')
    end
  end
end