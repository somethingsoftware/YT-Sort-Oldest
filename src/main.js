async function main() {
    console.log("yt sort by oldest fired")
    selector = document.querySelector("iron-selector.style-scope.ytd-feed-filter-chip-bar-renderer")
    if (!selector) {
        // retry until the selector is available
        for (let i = 0; true; i++) {
            console.log("yt sort by oldest retrying")
            await new Promise(resolve => setTimeout(resolve, 1000));
            selector = document.querySelector("iron-selector.style-scope.ytd-feed-filter-chip-bar-renderer")
            if (selector) {
                break;
            }
        }
    }
        selector.insertAdjacentHTML(
            'beforeend',
            `<yt-chip-cloud-chip-renderer 
                class="style-scope ytd-feed-filter-chip-bar-renderer" modern-chips="" 
                aria-selected="false" role="tab" tabindex="0" chip-style="STYLE_DEFAULT">
                <!--css-build:shady--> 
                <yt-formatted-string id="text" ellipsis-truncate="" 
                    class="style-scope yt-chip-cloud-chip-renderer" 
                    ellipsis-truncate-styling="" title="Oldest"> 
                    Oldest
                </yt-formatted-string>
            </yt-chip-cloud-chip-renderer>`);
    

}

main();
