# config.ru
run ->(env) {
  [200, { 'Content-Type' => 'text/plain' }, ["Hello world from Puma\n"]]
}
