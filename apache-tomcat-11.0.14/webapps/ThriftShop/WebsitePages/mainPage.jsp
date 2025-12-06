<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <% if (session.getAttribute("username")==null) { response.sendRedirect("../LoginPage/login.jsp"); return; } %>
        <!DOCTYPE html>
        <html>

        <head>
            <title>Main Page</title>
        </head>

        <body>
            <h3>User: <%= session.getAttribute("username") %>
            </h3>
            <h1>Welcome to Thrift Shop</h1>

            <nav>
                <ul>
                    <li><a href="tops.jsp">Tops</a></li>
                    <li><a href="bottoms.jsp">Bottoms</a></li>
                    <li><a href="shoes.jsp">Shoes</a></li>
                    <li><a href="notifications.jsp">Notifications</a></li>
                    <li><a href="profile.jsp">Profile</a></li>
                </ul>
            </nav>

        </body>

        <body>
        <script>

            document.addEventListener("DOMContentLoaded", function () {

                document.getElementById('itemsTypeSelect').addEventListener("change", function () {
                    const value = this.value;

                    if (value === "tops") {
                        document.getElementById('auctionFillOutFormTops').style.display = "block";
                        document.getElementById('auctionFillOutFormBottoms').style.display = "none";
                        document.getElementById('auctionFillOutFormShoes').style.display = "none";
                        document.getElementById('TopSubmit').style.display = "block";
                        document.getElementById('BottomSubmit').style.display = "none";
                        document.getElementById('ShoeSubmit').style.display = "none";
                    }
                    if (value === "bottoms") {
                        document.getElementById('auctionFillOutFormBottoms').style.display = "block";
                        document.getElementById('auctionFillOutFormTops').style.display = "none";
                        document.getElementById('auctionFillOutFormShoes').style.display = "none";
                        document.getElementById('BottomSubmit').style.display = "block";
                        document.getElementById('TopSubmit').style.display = "none";
                        document.getElementById('ShoeSubmit').style.display = "none";
                    }
                    if (value === "shoes") {
                        document.getElementById('auctionFillOutFormShoes').style.display = "block";
                        document.getElementById('auctionFillOutFormTops').style.display = "none";
                        document.getElementById('auctionFillOutFormBottoms').style.display = "none";
                        document.getElementById('ShoeSubmit').style.display = "block";
                        document.getElementById('TopSubmit').style.display = "none";
                        document.getElementById('BottomSubmit').style.display = "none";
                    }
                })
            })

            function createAuction() {
                document.getElementById('auctionFillOutForm').style.display = "block";
            }

        </script>

        <div id="auctionFillOutForm" style="display: none;">
            <label for="itemsType">Choose Item Type: </label>
            <select name="itemsType" id="itemsTypeSelect" required>
                <option value="selectAnItem" disabled selected>Select Item...</option>
                <option value="tops" id="tops">Tops</option>
                <option value="bottoms" id="bottoms">Bottoms</option>
                <option value="shoes" id="shoes">Shoes</option>
            </select>
        </div>

        <form action="tops.jsp" method="POST">
            <div id="auctionFillOutFormTops" style="display: none;">
                <label for="topGender">Gender: </label>
                <select name="topGender" id="topsGenderLabel" required>
                    <option value="SelectASize" disabled selected>Select Gender...</option>
                    <option value="Male">Male</option>
                    <option value="Female">Female</option>
                    <option value="Unisex">Unisex</option>
                </select>
                <label for="topSize">Top Size:</label>
                <select name="topSize" id="topSizeSelect" required>
                    <option value="SelectASize" disabled selected>Select Size...</option>
                    <option value="XS">XS</option>
                    <option value="S">S</option>
                    <option value="M">M</option>
                    <option value="L">L</option>
                    <option value="XL">XL</option>
                    <option value="XXL">XXL</option>
                    <option value="3XL">3XL</option>
                </select>
                <label for="topColor">Color: </label>
                <select name="topColor" id="TopColorColor" required>
                    <option value="SelectASize" disabled selected>Select Color...</option>
                    <option value="Black">Black</option>
                    <option value="Blue">Blue</option>
                    <option value="Gray">Gray</option>
                    <option value="White">White</option>
                    <option value="Brown">Brown</option>
                    <option value="Red">Red</option>
                    <option value="Pink">Pink</option>
                    <option value="Orange">Orange</option>
                    <option value="Yellow">Yellow</option>
                    <option value="Green">Green</option>
                    <option value="Purple">Purple</option>
                </select>
                <label for="FrontLength">Front Length (cm): </label>
                <input type="number" min="0" name="FrontLength" id="FrontLengthTop" required>
                <label for="ChestLength">Chest Length (cm): </label>
                <input type="number" min="0" name="ChestLength" id="ChestLengthTop" required>
                <label for="SleeveLength">Sleeve Length (cm): </label>
                <input type="number" min="0" name="SleeveLength" id="SleeveLengthTop" required>
                <label for="Description">Description: </label>
                <input name="Description" id="DescriptionTop" maxLength="200" required>
                <label for="Condition">Condition: </label>
                <input name="Condition" id="ConditionTop" maxLength="200" required>
                <label for="Minimum">Minimum Bid Price (USD): </label>
                <input type="number" min="0" name="Minimum" id="MinimumBidConditionTop" required>
                <label for="StartingOrCurrentBidPrice">Starting Bid Price(USD): </label>
                <input type="number" min="0" name="StartingOrCurrentBidPrice" id="StartingOrCurrentBidPriceTop"
                       required>
                <label for="AuctionCloseDateTops">Auction Close Date: </label>
                <input type="date" name="AuctionCloseDateTops" id="AuctionCloseTopsDate" required>
                <label for="AuctionCloseTime">Auction Close Time: </label>
                <input type="time" name="AuctionCloseTimeTops" id="AuctionCloseTopsTime" required>
            </div>
            <input type="submit" value="Submit" id="TopSubmit" style="display: none;" />
        </form>

        <form action="bottoms.jsp" method="POST">
            <div id="auctionFillOutFormBottoms" style="display: none;">
                <label for="bottomGender">Gender: </label>
                <select name="bottomGender" id="bottomGenderSelect" required>
                    <option value="SelectASize" disabled selected>Select Gender...</option>
                    <option value="Male">Male</option>
                    <option value="Female">Female</option>
                    <option value="Unisex">Unisex</option>
                </select>
                <label for="bottomSize">Bottom Size: </label>
                <select name="bottomSize" id="bottomSizeSelect" required>
                    <option value="SelectASize" disabled selected>Select Size...</option>
                    <option value="XS">XS</option>
                    <option value="S">S</option>
                    <option value="M">M</option>
                    <option value="L">L</option>
                    <option value="XL">XL</option>
                    <option value="XXL">XXL</option>
                    <option value="3XL">3XL</option>
                </select>
                <label for="bottomColor">Color: </label>
                <select name="bottomColor" id="bottomColorColor" required>
                    <option value="SelectASize" disabled selected>Select Color...</option>
                    <option value="Black">Black</option>
                    <option value="Blue">Blue</option>
                    <option value="Gray">Gray</option>
                    <option value="White">White</option>
                    <option value="Brown">Brown</option>
                    <option value="Red">Red</option>
                    <option value="Pink">Pink</option>
                    <option value="Orange">Orange</option>
                    <option value="Yellow">Yellow</option>
                    <option value="Green">Green</option>
                    <option value="Purple">Purple</option>
                </select>
                <label for="WaistLength">Waist Length (cm): </label>
                <input type="number" min="0" name="WaistLength" id="WaistLengthBottom" required>
                <label for="InseamLength">Inseam Length (cm): </label>
                <input type="number" min="0" name="InseamLength" id="InseamLengthBottom" required>
                <label for="OutseamLength">Outseam Length (cm): </label>
                <input type="number" min="0" name="OutseamLength" id="OutseamLengthBottom" required>
                <label for="HipLength">Hip Length (cm): </label>
                <input type="number" min="0" name="HipLength" id="HipLengthBottom" required>
                <label for="RiseLength">Rise Length (cm): </label>
                <input type="number" min="0" name="RiseLength" id="RiseLengthBottom" required>
                <label for="Description">Description: </label>
                <input name="Description" id="DescriptionBottom" required>
                <label for="Condition">Condition: </label>
                <input name="Condition" id="ConditionBottom" required>
                <label for="Minimum">Minimum Bid Price (USD): </label>
                <input type="number" min="0" name="Minimum" id="MinimumBidConditionBottom">
                <label for="AuctionCloseDateBottoms">Auction Close Date: </label>
                <input type="date" name="AuctionCloseDateBottoms" id="AuctionCloseBottomsDate">
                <label for="AuctionCloseTimeBottoms">Auction Close Time: </label>
                <input type="time" name="AuctionCloseTimeBottoms" id="AuctionCloseBottomsTime">
            </div>
            <input type="submit" value="Submit" id="BottomSubmit" style="display: none;" />
        </form>

        <form action="shoes.jsp" method="POST">
            <div id="auctionFillOutFormShoes" style="display: none;">
                <label for="shoeGender">Gender: </label>
                <select name="shoeGender" id="shoeGenderSelect" required>
                    <option value="SelectASize" disabled selected>Select Gender...</option>
                    <option value="Male">Male</option>
                    <option value="Female">Female</option>
                    <option value="Unisex">Unisex</option>
                </select>
                <label for="shoeSize">Shoe Size: </label>
                <select name="shoeSize" id="shoeSizeSelect" required>
                    <option value="SelectASize" disabled selected>Select Size...</option>
                    <option value="1">1</option>
                    <option value="2">2</option>
                    <option value="3">3</option>
                    <option value="4">4</option>
                    <option value="5">5</option>
                    <option value="6">6</option>
                    <option value="7">7</option>
                    <option value="8">8</option>
                    <option value="9">9</option>
                    <option value="10">10</option>
                    <option value="11">11</option>
                    <option value="12">12</option>
                    <option value="13">13</option>
                    <option value="14">14</option>
                    <option value="15">15</option>
                    <option value="16">16</option>
                    <option value="17">17</option>
                    <option value="18">18</option>
                    <option value="19">19</option>
                    <option value="20">20</option>
                    <option value="21">21</option>
                    <option value="22">22</option>
                    <option value="23">23</option>
                </select>
                <label for="shoeColor">Color: </label>
                <select type="color" name="shoeColor" id="ShoeColorColor" required>
                    <option value="SelectASize" disabled selected>Select Color...</option>
                    <option value="Black">Black</option>
                    <option value="Blue">Blue</option>
                    <option value="Gray">Gray</option>
                    <option value="White">White</option>
                    <option value="Brown">Brown</option>
                    <option value="Red">Red</option>
                    <option value="Pink">Pink</option>
                    <option value="Orange">Orange</option>
                    <option value="Yellow">Yellow</option>
                    <option value="Green">Green</option>
                    <option value="Purple">Purple</option>
                </select>
                <label for="Description">Description: </label>
                <input maxlength="200" name="Description" id="DescriptionShoe" required>
                <label for="Condition">Condition: </label>
                <input maxlength="200" name="Condition" id="ConditionShoe" required>
                <label for="Minimum">Minimum Bid Price (USD): </label>
                <input type="number" min="0" name="Minimum" id="MinimumBidConditionShoe">
                <label for="AuctionCloseDateShoes">Auction Close Date: </label>
                <input type="date" name="AuctionCloseDateShoes" id="AuctionCloseShoesDate">
                <label for="AuctionCloseTimeShoes">Auction Close Time: </label>
                <input type="time" name="AuctionCloseTimeShoes" id="AuctionCloseShoesDate">
            </div>
            <input type="submit" value="Submit" id="ShoeSubmit" style="display: none;" />
        </form>

        <button onclick='createAuction()'>create auction</button>
        </body>

        </html>