require 'wikipedia'

def revolutions
  puts "\nCreating classifier for Revolutions in Technology\n"
  train_on_wiki ['Neolithic Revolution', 'Industrial Revolution', 'Information revolution']
end

def phenomenology
  puts "\nCreating classifier for comparing Phenomenology to the rest of Philosophy\n"
  train_on_wiki ['Philosophy', 'Phenomenology (philosophy)']
end

def train_on_wiki topics
  classifier = ClassifierReborn::Bayes.new topics
  for i in topics
    page = Wikipedia.find i
    # trains on each main page
    puts "\nTraining on #{i} and all it's related pages...\n"
    classifier.train i, clean_wiki_text(page.text)
    for link in page.links
      link_page = Wikipedia.find link
      # trains on each link of each main page
      puts "Training on #{link} \n"
      classifier.train i, clean_wiki_text(link_page.text)
    end
  end
  return classifier
end

def clean_wiki_text text
  text.tr("\"", ' ')
      .tr("\n", ' ')
      .tr('===', ' ')
      .tr('==', ' ')
end
