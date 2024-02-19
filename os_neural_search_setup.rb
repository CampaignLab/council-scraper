
require 'opensearch'

# Initialize the client
client = OpenSearch::Client.new(url: 'http://localhost:9200')

# Based on tutorial
# https://opensearch.org/docs/latest/search-plugins/neural-search-tutorial/

# Define the settings you want to update
# "flat settings" format as specified https://docs.aws.amazon.com/opensearch-service/latest/developerguide/supported-operations.html#version_api_notes
settings = {
  persistent: {
    'plugins.ml_commons.only_run_on_ml_node': false,
    'plugins.ml_commons.native_memory_threshold': '99',
    'plugins.ml_commons.model_access_control_enabled': true
  }
}

# Update the cluster settings
response = os.api_client.cluster.put_settings(body: settings)
response = os.api_client.cluster.get_settings

body = {
  name: "NLP_model_group",
  description: "A model group for NLP models",
}

# Perform a POST request to register the model group
response = os.api_client.perform_request('POST', '/_plugins/_ml/model_groups/_register', {}, body.to_json)
model_group_id = response.body['model_group_id']

body = {
  "name": "huggingface/sentence-transformers/msmarco-distilbert-base-tas-b",
  "version": "1.0.1",
  "model_group_id": model_group_id,
  "model_format": "TORCH_SCRIPT"
}
response = os.api_client.perform_request('POST', '/_plugins/_ml/models/_register', {}, body.to_json)

task_id = response.body['task_id']
def wait_for_task_id(task_id)
  while true
    response = os.api_client.perform_request('GET', "/_plugins/_ml/tasks/#{task_id}")
    return if response.body['state'] == 'COMPLETED'
    puts "Current state: #{response.body['state']}"
    sleep 10
  end
end

response = wait_for_task_id(task_id)

model_id = response.body['model_id']

# DEPLOY MODEL
response = os.api_client.perform_request('POST', "/_plugins/_ml/models/#{model_id}/_deploy")
task_id = response.body['task_id']

response = wait_for_task_id(task_id)

# Create an Ingest Pipeline
pipeline_id = "nlp-ingest-pipeline"
pipeline_body = {
  description: "An NLP ingest pipeline",
  processors: [
    {
      text_embedding: {
        model_id: model_id,
        field_map: {
          "text": "passage_embedding"
        }
      }
    }
  ]
}

response = os.api_client.ingest.put_pipeline(id: pipeline_id, body: pipeline_body)

# Create an index which uses the pipeline
index_name = "my-nlp-index"
index_configuration = {
  settings: {
    "index.knn": true,
    "default_pipeline": "nlp-ingest-pipeline"
  },
  mappings: {
    properties: {
      id: {
        type: "text"
      },
      passage_embedding: {
        type: "knn_vector",
        dimension: 768,
        method: {
          engine: "lucene",
          space_type: "l2",
          name: "hnsw",
          parameters: {}
        }
      },
      text: {
        type: "text"
      }
    }
  }
}

# Create the index with the specified settings and mappings
response = os.api_client.indices.create(index: index_name, body: index_configuration)


# Print the response
puts response
