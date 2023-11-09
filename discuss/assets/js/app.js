// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})
let commentSocket = new Socket("/socket", {params: {token: window.userToken}})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

commentSocket.connect()

const createSocket = (topicId) => {
    let channel = commentSocket.channel(`comments:${topicId}` , {})
    channel.join()
        .receive("ok", resp => {
            console.log("Joined successfully", resp)
            renderComments(resp.comments)
        })
        .receive("error", resp => { console.log("Unable to join", resp) })

    channel.on(`comments:${topicId}:new`, renderComment)

    document.getElementById("add-comment").addEventListener("click", function() {
        let content = document.getElementById("message").value
        channel.push("comment:add", {content: content})
    })
}

function renderComments(comments) {
    const renderedComments = comments.map(comment => {
        return commentTemplate(comment)
    })
    document.querySelector(".collection").innerHTML = renderedComments.join("")
}

function renderComment(event) {
    document.querySelector(".collection").innerHTML += commentTemplate(event.comment)
}

function commentTemplate(comment) {
    let email = "Anonymous"
    if (comment.user) {
        email = comment.user.email
    }
    return `<li class="collection-item">
                ${comment.content}
                <div class="secondary-content">
                    ${email}
                </div>
            </li>`
}

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
window.createSocket = createSocket

