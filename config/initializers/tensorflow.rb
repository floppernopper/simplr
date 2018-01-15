if Rails.env.development? and false # turned off for now
  require 'tensorflow'
  def classify_image img
    scope_class = Tensorflow::Scope.new
    image_file = img.empty? ? (File.dirname(__FILE__) + '/mysore_palace.jpg') : img
    $stdout.puts "Trying to classify image file: #{image_file}"
    raise ArgumentError, "Cannot find image file: #{image_file}" unless File.file?(image_file)

    input = Const(scope_class, image_file)
    output = input.operation.g.AddOperation(Tensorflow::OpSpec.new('ReadFile', 'ReadFile', nil, [input]))
    output = input.operation.g.AddOperation(Tensorflow::OpSpec.new('DecodeJpeg',
      'DecodeJpeg', Hash['channels' => 3], [output.output(0)]))
    output = input.operation.g.AddOperation(Tensorflow::OpSpec.new('Cast', 'Cast', Hash['DstT' => 1], [output.output(0)]))
    output = input.operation.g.AddOperation(Tensorflow::OpSpec.new('ExpandDims',
      'ExpandDims', nil, [output.output(0), Const(scope_class.subscope('make_batch'), 0, :int32)]))
    output = input.operation.g.AddOperation(Tensorflow::OpSpec.new('ResizeBilinear',
      'ResizeBilinear', nil, [output.output(0), Const(scope_class.subscope('size'), [224, 224], :int32)]))
    output = input.operation.g.AddOperation(Tensorflow::OpSpec.new('Sub', 'Sub', nil,
      [output.output(0), Const(scope_class.subscope('mean'), 117.00, :float)]))
    output = input.operation.g.AddOperation(Tensorflow::OpSpec.new('Div', 'Div', nil,
      [output.output(0), Const(scope_class.subscope('scale'), 1.00, :float)])).output(0)
    graph = scope_class.graph
    session_op = Tensorflow::Session_options.new
    session = Tensorflow::Session.new(graph, session_op)
    out_tensor = session.run({}, [output], [])

    # Run inference on *imageFile.
    # For multiple images, session.Run() can be called in a loop (and
    # concurrently). Alternatively, images can be batched since the model
    # accepts batches of image data as input.
    graph = Tensorflow::Graph.new
    graph.read_file(Rails.root + 'lib/assets/tensorflow_inception_graph.pb')
    tensor = Tensorflow::Tensor.new(out_tensor[0], :float)
    sess = Tensorflow::Session.new(graph)
    hash = {}
    hash[graph.operation('input').output(0)] = tensor

    # predictions is a vector containing probabilities of
    # labels for each image in the "batch". The batch size was 1.
    # Find the most probably label index.
    predictions = sess.run(hash, [graph.operation('output').output(0)], [])

    predictions.flatten!
    labels = {}
    j = 0
    File.foreach(Rails.root + 'lib/assets/imagenet_comp_graph_label_strings.txt') do |line|
        labels[line] = predictions[j]
        j += 1
    end
    result = labels.sort { |a, b| b[1].to_f <=> a[1].to_f }
    puts 'The top five results are ', result[0..5]
    return result.first.first.split("\n").first
  end
end
