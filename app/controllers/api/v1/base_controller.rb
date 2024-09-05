module Api
  module V1
    class BaseController < ActionController::API

      before_action :authenticate_user

      def authenticate_user
        header_uid = request.headers['UID']
        header_token = request.headers['Authorization']&.split(' ')&.last
        
        if header_uid.present? && header_token.present?
          auth_payload = JwtAuth.decode(header_token)
          if auth_payload['uid'] == header_uid
            @current_user = User.find(auth_payload['uid'])
            @wallet = @current_user&.wallet
          end
        end

        render_json_unauthorized unless @current_user.present?
      end

      def render_json_unauthorized(message=nil)
        message = message || 'Unauthorized Request'
        render json: { message: message }, status: :unauthorized
      end

      def render_json_result(result=nil)
        return render_json_no_content if result.nil?

        case result[:status]
        when :success
          render_json_success(result[:status].to_s, result[:data])
        else
          render_json_failed result[:data]
        end
      end

      def render_json_success(status, data)
        render json: { code: 200, status: status, data: data }
      end

      def render_json_failed(data)
        render json: { code: 200, status: 'failed', data: data }
      end

      def render_json_unprocessable_entity(message=nil)
        render json: { errors: (message || 'Unprocessable Entity') }, status: :unprocessable_entity
      end

      def render_json_no_content(message=nil)
        render json: { errors: (message || 'No Content') }, status: :no_content
      end

      def render_json_bad_request(message=nil)
        message = message || 'Invalid Parameters'
        render json: { errors: message }, status: :bad_request
      end

    end
  end
end
