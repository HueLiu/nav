(function () {
  window.addEventListener("load", function () {
    clearLoading();
    adjustLayOut();
    // renderHitokoto();
    initializeToolTip();
    initializePopover();
  });

  const lastTheme = localStorage.getItem("theme");
  if (lastTheme) {
    document.documentElement.setAttribute("data-bs-theme", lastTheme);
  }

  window.addEventListener("resize", adjustLayOut);
  document.querySelector(".content-body")?.addEventListener("scroll", changeHeaderBg);

  document.getElementById("toggle-sidebar")?.addEventListener("click", toggleSidebar);
  document.getElementById("sidebar-container")?.addEventListener("click", toggleSidebar2);
  const sidebarCategories = document.querySelectorAll(".sidebar-item");
  const contentBody = document.querySelector(".content-body");
  sidebarCategories?.forEach((category) => {
    category.addEventListener("click", (event) => {
      document.getElementById("page-container")?.classList.remove("open-sidebar");
      event.preventDefault();
      let categoryId = category.getAttribute("data-id");
      let categoryIdArray;
      let categoryElement;
      if (!categoryId) {
        const href = category.getAttribute("href");
        if (!href?.startsWith("#")) {
          window.open(href, "_blank");
          return;
        } else {
          categoryElement = document.querySelector(href);
        }
      } else {
        categoryIdArray = categoryId.split("-");
        categoryElement = categoryIdArray.length <= 2 ? document.getElementById(categoryId) : document.getElementById(categoryIdArray[0] + "-" + categoryIdArray[1]);
      }
      contentBody?.scrollTo({
        top: categoryElement.offsetTop - 64,
        behavior: "smooth"
      });
      (categoryIdArray?.length > 2) && document.getElementById(categoryId)?.click();
    });
  });

  addContentSearchSwitchListener();
  const searchBtn = document.getElementById("search-btn");
  searchBtn?.addEventListener("click", () => {
    const searchText = document.getElementById("search-text")?.value;
    const url = searchBtn?.getAttribute("data-url");
    searchText && url && window.open(url + searchText, "_blank");
  });

  const linkBtnList = document.querySelectorAll(".link");
  linkBtnList?.forEach((btn) => {
    btn.addEventListener("click", (event) => {
      event.preventDefault();
      const tooltip = bootstrap.Tooltip.getInstance(btn);
      tooltip?.hide();
      const link = btn.getAttribute("data-link");
      link && window.open(link, "_target");
    });
  });

  const openLinkBtnList = document.querySelectorAll(".link .open-link");
  openLinkBtnList?.forEach((btn) => {
    btn.addEventListener("click", (event) => {
      event.stopPropagation();
      const link = btn.getAttribute("data-link");
      link && window.open(link, "_self");
    });
  });

  const switchThemeBtn = document.querySelector(".switch-theme");
  switchThemeBtn?.addEventListener("click", () => {
    const currentTheme = document.documentElement.getAttribute("data-bs-theme");
    const newTheme = currentTheme === "dark" ? "light" : "dark";
    document.documentElement.setAttribute("data-bs-theme", newTheme);
    localStorage.setItem("theme", newTheme);
  });

  addModalSearchSwitchListener();
  const modalSearchBtn = document.getElementById("modal-search-btn");
  modalSearchBtn?.addEventListener("click", () => {
    const searchText = document.getElementById("modal-search-text")?.value;
    const url = modalSearchBtn?.getAttribute("data-url");
    searchText && url && window.open(url + searchText, "_blank");
  });
})();

function clearLoading() {
  const loader = document.querySelector(".loader-container");
  loader && setTimeout(() => loader.remove(), 1000);
}

function renderHitokoto() {
  fetch("https://v1.hitokoto.cn")
    .then(response => response.json())
    .then(data => {
      const hitokoto = document.getElementById("hitokoto_text");
      hitokoto.href = "https://hitokoto.cn/?uuid=" + data.uuid;
      hitokoto.innerText = data.hitokoto;
    })
    .catch(console.error);
}

function adjustLayOut() {
  const pageContainer = document.getElementById("page-container");
  const classList = pageContainer?.classList || [];
  const windowWidth = window.innerWidth;
  if (windowWidth >= 992) {
    pageContainer.classList.remove("mini-sidebar");
    pageContainer.classList.remove("hide-sidebar");
    pageContainer.classList.remove("open-sidebar");
  } else if (windowWidth >= 768) {
    if (!classList.contains("mini-sidebar")) {
      pageContainer.classList.add("mini-sidebar");
    }
    pageContainer.classList.remove("hide-sidebar");
    pageContainer.classList.remove("open-sidebar");
  } else {
    pageContainer.classList.remove("mini-sidebar");
    if (!classList.contains("hide-sidebar")) {
      pageContainer.classList.add("hide-sidebar");
    }
    pageContainer.classList.remove("open-sidebar");
  }
}

function changeHeaderBg(event) {
  const contentHeader = document.querySelector(".content-header");
  const goToTopBtn = document.querySelector(".go-to-top");
  if (event.target.scrollTop > 0) {
    contentHeader.classList.add("bg-header");
    goToTopBtn?.classList.remove("d-none");
  } else {
    contentHeader.classList.remove("bg-header");
    goToTopBtn?.classList.add("d-none");
  }
}

function toggleSidebar(event) {
  event.preventDefault();
  const pageContainer = document.getElementById("page-container");
  const windowWidth = window.innerWidth;
  if (windowWidth >= 768) {
    pageContainer.classList.toggle("mini-sidebar");
  } else {
    pageContainer.classList.toggle("open-sidebar");
  }
}

function toggleSidebar2(event) {
  if (event.target.id !== "sidebar-container") return;
  event.preventDefault();
  const pageContainer = document.getElementById("page-container");
  const windowWidth = window.innerWidth;
  if (windowWidth < 768) {
    pageContainer.classList.toggle("open-sidebar");
  }
}

function addContentSearchSwitchListener() {
  const handleSearchInput = (element) => {
    const searchInput = document.getElementById("search-text");
    const searchBtn = document.getElementById("search-btn");
    searchInput?.setAttribute("placeholder", element.getAttribute("data-description"));
    searchBtn?.setAttribute("data-url", element.getAttribute("data-url"));
  };

  const searchMenuList = document.querySelectorAll(".content-search .search-menu .nav-link");
  searchMenuList?.forEach(item => item.addEventListener("click", (event) => {
    const activeItemSelector = event.target.getAttribute("href");
    const activeItem = document.querySelector(activeItemSelector + " .nav-link.active");
    activeItem && handleSearchInput(activeItem);
  }));
  const searchItemList = document.querySelectorAll(".content-search .tab-content .nav-link");
  searchItemList?.forEach(item => item.addEventListener("click", (event) => {
    handleSearchInput(event.target);
  }));
}

function addModalSearchSwitchListener() {
  const handleSearchInput = (element) => {
    const searchInput = document.getElementById("modal-search-text");
    const searchBtn = document.getElementById("modal-search-btn");
    searchInput?.setAttribute("placeholder", element.getAttribute("data-description"));
    searchBtn?.setAttribute("data-url", element.getAttribute("data-url"));
  };

  const searchMenuList = document.querySelectorAll(".modal-search .search-menu .nav-link");
  searchMenuList?.forEach(item => item.addEventListener("click", (event) => {
    const activeItemSelector = event.target.getAttribute("href");
    const activeItem = document.querySelector(activeItemSelector + " .nav-link.active");
    activeItem && handleSearchInput(activeItem);
  }));
  const searchItemList = document.querySelectorAll(".modal-search .tab-content .nav-link");
  searchItemList?.forEach(item => item.addEventListener("click", (event) => {
    handleSearchInput(event.target);
  }));
}

function initializeToolTip() {
  const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]');
  const tooltipList = [...tooltipTriggerList].map(element => new bootstrap.Tooltip(element));
}

function initializePopover() {
  const myDefaultAllowList = bootstrap.Tooltip.Default.allowList;
  myDefaultAllowList['a'].push('data-id');

  const popoverTriggerList = document.querySelectorAll('[data-bs-toggle="popover"]');
  const popoverList = [...popoverTriggerList].map(element => new bootstrap.Popover(element));
  popoverList.forEach((popover) => {
    popover._element.addEventListener("mouseenter", function (event) {
      const pageContainer = document.getElementById("page-container");
      const classList = pageContainer?.classList || [];
      if (!classList.contains("mini-sidebar")) {
        return;
      }
      const popoverId = popover._element.getAttribute("aria-describedby");
      const popoverEl = document.getElementById(popoverId);
      if (popoverEl && (event.fromElement == popoverEl || popoverEl.contains(event.fromElement))) {
        return;
      }

      popover.toggle();
    });
    popover._element.addEventListener("mouseleave", function (event) {
      const pageContainer = document.getElementById("page-container");
      const classList = pageContainer?.classList || [];
      if (!classList.contains("mini-sidebar")) {
        return;
      }
      const popoverId = popover._element.getAttribute("aria-describedby");
      const popoverEl = document.getElementById(popoverId);
      if (!popoverEl || event.toElement == popoverEl || popoverEl.contains(event.toElement)) {
        popoverEl?.addEventListener("mouseleave", function (event) {
          if ((event.toElement == popover._element || popover._element.contains(event.toElement))) {
            return;
          }
          popover.toggle();
        }, { once: true });
        return;
      }
      popover.toggle();
    });
    popover._element.addEventListener("shown.bs.popover", function () {
      const popoverId = popover._element.getAttribute("aria-describedby");
      const popoverEl = document.getElementById(popoverId);
      const categories = popoverEl?.querySelectorAll(".sidebar-item");
      const contentBody = document.querySelector(".content-body");
      categories?.forEach((category) => {
        category.addEventListener("click", (event) => {
          event.preventDefault();
          const categoryId = category.getAttribute("data-id");
          const categoryIdArray = categoryId.split("-");
          const categoryElement = categoryIdArray.length == 2 ? document.getElementById(categoryId) : document.getElementById(categoryIdArray[0] + "-" + categoryIdArray[1]);
          contentBody?.scrollTo({
            top: categoryElement.offsetTop - 64,
            behavior: "smooth"
          });
          (categoryIdArray.length > 2) && document.getElementById(categoryId)?.click();
        });
      });
    });
  });
}
