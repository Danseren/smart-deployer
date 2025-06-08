// Populate the sidebar
//
// This is a script, and not included directly in the page, to control the total size of the book.
// The TOC contains an entry for each page, so if each page includes a copy of the TOC,
// the total size of the page becomes O(n**2).
class MDBookSidebarScrollbox extends HTMLElement {
    constructor() {
        super();
    }
    connectedCallback() {
        this.innerHTML = '<ol class="chapter"><li class="chapter-item "><a href="index.html">Home</a></li><li class="chapter-item affix "><li class="part-title">contracts</li><li class="chapter-item "><a href="contracts/DeployManager/index.html">❱ DeployManager</a><a class="toggle"><div>❱</div></a></li><li><ol class="section"><li class="chapter-item "><a href="contracts/DeployManager/DeployManager.sol/contract.DeployManager.html">DeployManager</a></li><li class="chapter-item "><a href="contracts/DeployManager/IDeployManager.sol/interface.IDeployManager.html">IDeployManager</a></li></ol></li><li class="chapter-item "><a href="contracts/ERC1155Airdroper/index.html">❱ ERC1155Airdroper</a><a class="toggle"><div>❱</div></a></li><li><ol class="section"><li class="chapter-item "><a href="contracts/ERC1155Airdroper/ERC1155Airdroper.sol/contract.ERC1155Airdroper.html">ERC1155Airdroper</a></li></ol></li><li class="chapter-item "><a href="contracts/ERC20Airdroper/index.html">❱ ERC20Airdroper</a><a class="toggle"><div>❱</div></a></li><li><ol class="section"><li class="chapter-item "><a href="contracts/ERC20Airdroper/ERC20Airdroper.sol/contract.ERC20Airdroper.html">ERC20Airdroper</a></li></ol></li><li class="chapter-item "><a href="contracts/ERC721Airdroper/index.html">❱ ERC721Airdroper</a><a class="toggle"><div>❱</div></a></li><li><ol class="section"><li class="chapter-item "><a href="contracts/ERC721Airdroper/ERC721Airdroper.sol/contract.ERC721Airdroper.html">ERC721Airdroper</a></li></ol></li><li class="chapter-item "><a href="contracts/UtilityContract/index.html">❱ UtilityContract</a><a class="toggle"><div>❱</div></a></li><li><ol class="section"><li class="chapter-item "><a href="contracts/UtilityContract/AbstractUtilityContract.sol/abstract.AbstractUtilityContract.html">AbstractUtilityContract</a></li><li class="chapter-item "><a href="contracts/UtilityContract/IUtilityContract.sol/interface.IUtilityContract.html">IUtilityContract</a></li></ol></li><li class="chapter-item "><a href="contracts/Vesting/index.html">❱ Vesting</a><a class="toggle"><div>❱</div></a></li><li><ol class="section"><li class="chapter-item "><a href="contracts/Vesting/IVesting.sol/interface.IVesting.html">IVesting</a></li><li class="chapter-item "><a href="contracts/Vesting/Vesting.sol/contract.Vesting.html">Vesting</a></li><li class="chapter-item "><a href="contracts/Vesting/VestingLib.sol/library.VestingLib.html">VestingLib</a></li></ol></li><li class="chapter-item "><a href="contracts/ERC20Mock.sol/contract.ERC20Mock.html">ERC20Mock</a></li></ol>';
        // Set the current, active page, and reveal it if it's hidden
        let current_page = document.location.href.toString().split("#")[0];
        if (current_page.endsWith("/")) {
            current_page += "index.html";
        }
        var links = Array.prototype.slice.call(this.querySelectorAll("a"));
        var l = links.length;
        for (var i = 0; i < l; ++i) {
            var link = links[i];
            var href = link.getAttribute("href");
            if (href && !href.startsWith("#") && !/^(?:[a-z+]+:)?\/\//.test(href)) {
                link.href = path_to_root + href;
            }
            // The "index" page is supposed to alias the first chapter in the book.
            if (link.href === current_page || (i === 0 && path_to_root === "" && current_page.endsWith("/index.html"))) {
                link.classList.add("active");
                var parent = link.parentElement;
                if (parent && parent.classList.contains("chapter-item")) {
                    parent.classList.add("expanded");
                }
                while (parent) {
                    if (parent.tagName === "LI" && parent.previousElementSibling) {
                        if (parent.previousElementSibling.classList.contains("chapter-item")) {
                            parent.previousElementSibling.classList.add("expanded");
                        }
                    }
                    parent = parent.parentElement;
                }
            }
        }
        // Track and set sidebar scroll position
        this.addEventListener('click', function(e) {
            if (e.target.tagName === 'A') {
                sessionStorage.setItem('sidebar-scroll', this.scrollTop);
            }
        }, { passive: true });
        var sidebarScrollTop = sessionStorage.getItem('sidebar-scroll');
        sessionStorage.removeItem('sidebar-scroll');
        if (sidebarScrollTop) {
            // preserve sidebar scroll position when navigating via links within sidebar
            this.scrollTop = sidebarScrollTop;
        } else {
            // scroll sidebar to current active section when navigating via "next/previous chapter" buttons
            var activeSection = document.querySelector('#sidebar .active');
            if (activeSection) {
                activeSection.scrollIntoView({ block: 'center' });
            }
        }
        // Toggle buttons
        var sidebarAnchorToggles = document.querySelectorAll('#sidebar a.toggle');
        function toggleSection(ev) {
            ev.currentTarget.parentElement.classList.toggle('expanded');
        }
        Array.from(sidebarAnchorToggles).forEach(function (el) {
            el.addEventListener('click', toggleSection);
        });
    }
}
window.customElements.define("mdbook-sidebar-scrollbox", MDBookSidebarScrollbox);
