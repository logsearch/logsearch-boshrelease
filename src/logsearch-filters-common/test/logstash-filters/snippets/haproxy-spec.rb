# encoding: utf-8
require 'test/filter_test_helpers'

describe "Rules for parsing haproxy messages" do

  before(:all) do
    @config = <<-CONFIG
      filter {
    #{File.read("src/logstash-filters/snippets/haproxy.conf")}
      }
    CONFIG
  end

  context 'when parsing a sylog message in RFC3164 format from haproxy' do
    context "when parsing failure messages" do
      when_parsing_log(
        '@message' => "94.199.134.2:58725 [17/Dec/2015:11:45:37.547] syslog-in/1: SSL handshake failure",
        'syslog_program' => "haproxy"
      ) do

        it "adds the syslog_standard tag" do
          expect(log['tags']).to include("haproxy")
        end
        it "extract the message" do
          expect(log['haproxy']['message']).to include("SSL handshake failure")
        end
      end
      when_parsing_log(
        '@message' => 'Server ingestors/node0 is DOWN, reason: Layer4 connection problem, info: "Connection refused", check duration: 0ms. 0 active and 0 backup servers left. 52 sessions active, 0 requeued, 0 remaining in queue.',
        'syslog_program' => "haproxy"
      ) do

        it "adds the syslog_standard tag" do
          expect(log['tags']).to include("haproxy")
        end
        it "extract the message" do
          expect(log['haproxy']['message']).to eq('Server ingestors/node0 is DOWN, reason: Layer4 connection problem, info: "Connection refused", check duration: 0ms. 0 active and 0 backup servers left. 52 sessions active, 0 requeued, 0 remaining in queue.')
        end
      end
    end

    context "when parsing startup messages" do
      when_parsing_log(
        '@message' => "Proxy ingestors started.",
        'syslog_program' => "haproxy"
      ) do

        it "adds the syslog_standard tag" do
          expect(log['tags']).to include("haproxy")
        end
        it "extract the message" do
          expect(log['haproxy']['message']).to eq("Proxy ingestors started.")
        end
      end
    end

    context "when parsing connection details" do
      when_parsing_log(
        '@message' => "52.62.56.30:45940 [16/Dec/2015:15:24:02.638] syslog-in~ ingestors/node1 328/-1/3332 0 SC 8/8/8/0/3 0/0",
        'syslog_program' => "haproxy"
      ) do

        it "adds the syslog_standard tag" do
          expect(log['tags']).to include("haproxy")
        end

        it "removes the @message field after parsing successfully" do
          expect(log['tags']).to include("haproxy")
          expect(log['@message']).to be_nil
        end

        it "extracts haproxy log attributes" do
          expect(log["haproxy"]).to_not be_nil
        end

        it "extracts the client IP" do
          expect(log["haproxy"]["client_ip"]).to eq "52.62.56.30"
        end

        it "extracts the client port" do
          expect(log["haproxy"]["client_port"]).to eq 45940
        end

        it "extracts the accept_date" do
          expect(log["haproxy"]["accept_date"]).to eq(Time.parse('2015-12-16T15:24:02.638Z'))
        end

        it "extracts the frontend_name" do
          expect(log["haproxy"]["frontend_name"]).to eq("syslog-in~")
        end

        it "extracts the backend_name" do
          expect(log["haproxy"]["backend_name"]).to eq("ingestors")
        end

        it "extracts the time_queue in ms" do
          expect(log["haproxy"]["time_queue_ms"]).to eq(328)
        end

        it "extracts the time_backend_connect in ms" do
          expect(log["haproxy"]["time_backend_connect_ms"]).to eq(-1)
        end

        it "extracts the time_duration in ms" do
          expect(log["haproxy"]["time_duration_ms"]).to eq 3332
        end

        it "extracts the bytes_read" do
          expect(log["haproxy"]["bytes_read"]).to eq 0
        end

        it "parses the termination state" do
          expect(log["haproxy"]["termination_state"]).to eq "SC"
        end

        it "parses the number of concurrent connections" do
          expect(log["haproxy"]["actconn"]).to eq 8
        end

        it "parses the number of concurrent connections on the frontend" do
          expect(log["haproxy"]["feconn"]).to eq 8
        end

        it "parses the number of concurrent connections on the backend" do
          expect(log["haproxy"]["beconn"]).to eq 8
        end

        it "parses the number of concurrent connections on the server" do
          expect(log["haproxy"]["srvconn"]).to eq 0
        end

        it "parses the number of connection retries" do
          expect(log["haproxy"]["retries"]).to eq 3
        end

        it "parses the number of connections in the service queue" do
          expect(log["haproxy"]["srv_queue"]).to eq 0
        end

        it "parses the number of connections in the backend queue" do
          expect(log["haproxy"]["backend_queue"]).to eq 0
        end

        it "@message should be empty, all information has been extracted into specific keys" do
          expect(log["@message"]).to be_nil
        end
      end

      context "when the client aborts the connection" do
        when_parsing_log(
          '@message' => "52.62.56.30:45940 [16/Dec/2015:15:24:02.638] syslog-in~ ingestors/node1 328/-1/3332 0 CD 8/8/8/0/3 0/0",
          'syslog_program' => "haproxy"
        ) do

          it "populates the termination description" do
            expect(log["@message"]).to eq "Session unexpectedly aborted by client"
          end
        end
      end

      context "when the client sends no data" do
        when_parsing_log(
          '@message' => "52.62.56.30:45940 [16/Dec/2015:15:24:02.638] syslog-in~ ingestors/node1 328/-1/3332 0 cD 8/8/8/0/3 0/0",
          'syslog_program' => "haproxy"
        ) do

          it "populates the termination description" do
            expect(log["@message"]).to eq "Client-side timeout expired"
          end
        end
      end

      context "when the backend sends no data" do
        when_parsing_log(
          '@message' => "52.62.56.30:45940 [16/Dec/2015:15:24:02.638] syslog-in~ ingestors/node1 328/-1/3332 0 sD 8/8/8/0/3 0/0",
          'syslog_program' => "haproxy"
        ) do

          it "populates the termination description" do
            expect(log["@message"]).to eq "Server-side timeout expired"
          end
        end
      end
    end
  end
end
