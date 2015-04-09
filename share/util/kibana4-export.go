//
// This script will export one or more kibana4 dashboards (including any
// visualization and search object dependencies they may have). The output is
// in a format which can be piped to an elasticsearch bulk request endpoint.
//
// For example:
//
//     $ kibana4-export -host=kibana4.logsearch.example.com logsearch-pipeline \
//         | curl --data-binary=@- api.logsearch2.example.com:9200/_bulk
//     $ open kibana4.logsearch2.example.com/#/dashboard/logsearch-pipeline
//

package main

import (
  "bytes"
  "errors"
  "flag"
  "fmt"
  "encoding/json"
  "io/ioutil"
  "net/http"
  "strconv"
)

var flagHost string
var flagPort int

var discoDone map[string] bool

func init() {
  flag.StringVar(&flagHost, "host", "127.0.0.1", "kibana4 host/ip")
  flag.IntVar(&flagPort, "port", 5601, "kibana4 port")
}

func main() {
  flag.Parse()
  
  discoDone = make(map[string] bool)
  
  for _, dashboard := range flag.Args() {
    requireDashboard(dashboard)
  }
}

//
// getDocument will load the source of a a kibana4 object.
// If it has already been discovered, the function will return early with
// handled set to true.
//
func getDocument(ktype string, kid string) (doc map[string]interface{}, handled bool, err error) {
  discoKey := fmt.Sprintf("%s:%s", ktype, kid)
  
  if _, handled = discoDone[discoKey]; handled {
    return
  }

  res, err := http.Post(
    fmt.Sprintf("http://%s:%s/elasticsearch/_mget", flagHost, strconv.Itoa(flagPort)),
    "application/json",
    bytes.NewBufferString(fmt.Sprintf("{\"docs\":[{\"_index\":\".kibana\",\"_type\":\"%s\",\"_id\":\"%s\"}]}", ktype, kid)),
  )

  if err != nil {
    return
  }

  defer res.Body.Close()
  body, err := ioutil.ReadAll(res.Body)

  if err != nil {
    return
  }

  var data map[string]interface{}

  err = json.Unmarshal(body, &data)

  if err != nil {
    return
  }

  docpath := data["docs"].([]interface{})[0].(map[string]interface{})
    
  if true != docpath["found"].(bool) {
    err = errors.New(fmt.Sprintf("Failed to find %s %s", ktype, kid))
    
    return
  }
  
  doc = docpath["_source"].(map[string]interface{})
  
  discoDone[discoKey] = true

  return
}

//
// dumpDocument will serialize a kibana4 object type into an elasticsearch bulk
// request statement.
//
func dumpDocument(ktype string, kid string, doc map[string]interface{}) {
  docjson, err := json.Marshal(doc)

  if err != nil {
    panic(err)
  }

  fmt.Println(fmt.Sprintf("{\"index\":{\"_index\":\".kibana\",\"_type\":\"%s\",\"_id\":\"%s\"}}", ktype, kid))
  fmt.Println(string(docjson))
}

//
// requireSearch will download a kibana4 search and ensure all its dependencies
// will also be dumped.
//
func requireSearch(id string) {
  doc, handled, err := getDocument("search", id)

  if handled {
    return
  } else if err != nil {
    panic(err)
  }
  
  dumpDocument("search", id, doc)
}

//
// requireVisualization will download a kibana4 visualization and ensure all
// its dependencies will also be dumped.
//
func requireVisualization(id string) {
  doc, handled, err := getDocument("visualization", id)

  if handled {
    return
  } else if err != nil {
    panic(err)
  }
  
  if val, ok := doc["savedSearchId"]; ok {
      requireSearch(val.(string))
  }

  dumpDocument("visualization", id, doc)
}

//
// requireDashboard will download a kibana4 dashboard and ensure all
// its dependencies will also be dumped.
//
func requireDashboard(id string) {
  doc, handled, err := getDocument("dashboard", id)

  if handled {
    return
  } else if err != nil {
    panic(err)
  }
  
  var panelsJSON []interface{}
  
  err = json.Unmarshal([]byte(doc["panelsJSON"].(string)), &panelsJSON)
  
  if err != nil {
    panic(err)
  }
  
  for _, panel := range panelsJSON {
    vtype := panel.(map[string]interface{})["type"].(string)
    vid := panel.(map[string]interface{})["id"].(string)

    if "visualization" == vtype {
      requireVisualization(vid)
    } else if "search" == vtype {
      requireSearch(vid)
    } else {
      panic(fmt.Sprintf("Unexpected panel type: %s", vtype))
    }
  }

  dumpDocument("dashboard", id, doc)
}
