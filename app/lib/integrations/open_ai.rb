class Integrations::OpenAi
    attr_reader :client, :model

    def initialize(model: nil)
        @client = OpenAI::Client.new
        @model = model || ENV['OPENAI_MODEL']
    end

    def count_input_tokens(text)
        OpenAI.rough_token_count(text)
    end

    def chat(input)
        response = client.chat(
            parameters: {
                model: model,
                messages: [{ role: "user", content: input }],
                temperature: 0, # 0 should produce little creative output/variety, which is what we probably want
            })
        {
            response: response.dig("choices", 0, "message", "content"),
            input_tokens: response.dig("usage", "prompt_tokens"),
            output_tokens: response.dig("usage", "completion_tokens"),
            model: model
        }
    end
end