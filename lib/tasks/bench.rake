namespace :bench do
  def create_fixtures count
    count.times.map { |n| { name: "name_#{n}", genres: ["genre_#{n}"] } }
  end

  def sample_ids_of model, count
    ids = model.pluck(:id)
    ids.shuffle.take(count)
  end

  def puts_bench_name task_name
    puts "\n###################################################################\n\n"
    puts "#{task_name}"
  end

  def models_list
    [
      MetkaSong,
      ActsAsTaggableOn::Tagging,
      ActsAsTaggableOn::Tag,
      ActsAsTaggableSong,
      ActsAsTaggableArraySong,
      TagColumnsSong
    ]
  end

  desc 'run all benchmarks'
  task all: %i(write read find_by_tag) do
    puts "\nFinished all benchmarks"
  end

  desc 'delete all records from benchmarked models'
  task clean: :environment do
    models_list.each do |model|
      if model.delete_all > 0
        puts "Deleted all #{model.name}"
      end
    end
    puts 'Finished to clean'
  end

  desc 'run benchmark on database write performance'
  task write: :clean do |task_name|
    trial_count = 1000
    data = create_fixtures trial_count

    puts_bench_name task_name

    puts "\nTime measurements:\n\n"
    Benchmark.bmbm(22) do |bench|
      bench.report('Metka:') do
        data.each { |attrs| MetkaSong.create name: attrs[:name], genre_list: attrs[:genres] }
      end
      bench.report('ActsAsTaggableOn:') do
        data.each { |attrs| ActsAsTaggableSong.create name: attrs[:name], genre_list: attrs[:genres]  }
      end
      bench.report('ActsAsTaggableOnArray:') do
        data.each { |attrs| ActsAsTaggableArraySong.create name: attrs[:name], genres: attrs[:genres] }
      end
      bench.report('TagColumns:') do
        data.each { |attrs| TagColumnsSong.create name: attrs[:name], genres: attrs[:genres] }
      end
    end

    puts "\nMemory measurements:\n\n"
    Benchmark.memory do |bench|
      bench.report('Metka:') do
        data.each { |attrs| MetkaSong.create name: attrs[:name], genre_list: attrs[:genres] }
      end
      bench.report('ActsAsTaggableOn:') do
        data.each { |attrs| ActsAsTaggableSong.create name: attrs[:name], genre_list: attrs[:genres]  }
      end
      bench.report('ActsAsTaggableOnArray:') do
        data.each { |attrs| ActsAsTaggableArraySong.create name: attrs[:name], genres: attrs[:genres] }
      end
      bench.report('TagColumns:') do
        data.each { |attrs| TagColumnsSong.create name: attrs[:name], genres: attrs[:genres] }
      end
    end
  end

  desc 'run benchmark on database read tags performance'
  task read: :environment do |task_name|
    if models_list.map(&:count).detect { |counter| counter == 0 }.present?
      puts 'First you need to run write task: \'rake bench:write\''
    else
      puts_bench_name task_name

      trial_count = 1000
      metka_sample_ids = sample_ids_of MetkaSong, trial_count
      acts_as_taggable_array_sample_ids = sample_ids_of ActsAsTaggableArraySong, trial_count
      tag_columns_sample_ids = sample_ids_of TagColumnsSong, trial_count
      acts_as_taggable_sample_ids = sample_ids_of ActsAsTaggableSong, trial_count

      puts "\nTime measurements:\n\n"
      Benchmark.bmbm(22) do |bench|
        bench.report('Metka:') do
          metka_sample_ids.each { |id| MetkaSong.find(id).genre_list }
        end
        bench.report('ActsAsTaggableOn:') do
          acts_as_taggable_sample_ids.each { |id| ActsAsTaggableSong.find(id).genre_list }
        end
        bench.report('ActsAsTaggableOnArray:') do
          acts_as_taggable_array_sample_ids.each { |id| ActsAsTaggableArraySong.find(id).genres }
        end
        bench.report('TagColumns:') do
          tag_columns_sample_ids.each { |id| TagColumnsSong.find(id).genres }
        end
      end

      puts "\nMemory measurements:\n\n"
      Benchmark.memory do |bench|
        bench.report('Metka:') do
          metka_sample_ids.each { |id| MetkaSong.find(id).genre_list }
        end
        bench.report('ActsAsTaggableOn:') do
          acts_as_taggable_sample_ids.each { |id| ActsAsTaggableSong.find(id).genre_list }
        end
        bench.report('ActsAsTaggableOnArray:') do
          acts_as_taggable_array_sample_ids.each { |id| ActsAsTaggableArraySong.find(id).genres }
        end
        bench.report('TagColumns:') do
          tag_columns_sample_ids.each { |id| TagColumnsSong.find(id).genres }
        end
      end
    end
  end

  desc 'run benchmark on database find by tags performance'
  task find_by_tag: :environment do |task_name|
    if models_list.map(&:count).detect { |counter| counter == 0 }.present?
      puts 'First you need to run write task: \'rake bench:write\''
    else
      puts_bench_name task_name

      trial_count = 1000
      data = create_fixtures trial_count
      genres = data.map { |attrs| attrs[:genres_list] }
      genre_samplers = genres.flatten.shuffle.take(trial_count)

      puts "\nTime measurements:\n\n"
      Benchmark.bmbm(22) do |bench|
        bench.report('Metka:') do
          genre_samplers.each { |genre| MetkaSong.with_any_genres genre }
        end
        bench.report('ActsAsTaggableOn:') do
          genre_samplers.each { |genre| ActsAsTaggableSong.tagged_with genre, on: :genres, any: true }
        end
        bench.report('ActsAsTaggableOnArray:') do
          genre_samplers.each { |genre| ActsAsTaggableArraySong.with_any_genres genre }
        end
        bench.report('TagColumns:') do
          genre_samplers.each { |genre| TagColumnsSong.with_any_genres genre }
        end
      end

      puts "\nMemory measurements:\n\n"
      Benchmark.memory do |bench|
        bench.report('Metka:') do
          genre_samplers.each { |genre| MetkaSong.with_any_genres genre }
        end
        bench.report('ActsAsTaggableOn:') do
          genre_samplers.each { |genre| ActsAsTaggableSong.tagged_with genre, on: :genres, any: true }
        end
        bench.report('ActsAsTaggableOnArray:') do
          genre_samplers.each { |genre| ActsAsTaggableArraySong.with_any_genres genre }
        end
        bench.report('TagColumns:') do
          genre_samplers.each { |genre| TagColumnsSong.with_any_genres genre }
        end
      end
    end
  end

  # TODO: add benchmarks for TagClouds (and, maybe, it would also be worth to do so with View Strategies, but it's
  # worth noting, that Metka MaterializedView creation would probably affect all other benchmarks, so we probably
  # should also create an additional model just for that MaterializedView), maybe ViewBenchmarks should be put to a
  # separated benchmark, since this one is already quite rich with different data
end
